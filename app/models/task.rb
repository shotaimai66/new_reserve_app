class Task < ApplicationRecord
  after_create_commit { TaskBroadcastJob.perform_later self }
  acts_as_paranoid
  validate :check_time_original
  validate :check_include_work_time
  validate :start_end_check
  validate :check_after_timenow
  validate :check_calendar_holiday

  belongs_to :task_course, optional: true
  belongs_to :store_member, optional: true
  belongs_to :calendar
  belongs_to :staff, optional: true

  scope :member_tasks, ->(store_member) { where(store_member_id: store_member.id) }
  scope :expect_past, -> { where('start_time >= ?', Time.current) }
  scope :future_tasks, -> { where('start_time >= ?', Time.current) }
  scope :staff_tasks, ->(staff) { where(staff_id: staff.id) }
  scope :today_tasks, -> { where('start_time >= ? && start_time <= ?', Time.current.beginning_of_day, Time.current.end_of_day) }
  scope :tomorrow_tasks, -> { where(start_time: Time.current.tomorrow.all_day) }
  scope :prev_task, -> { where('start_time < ?', Time.current.beginning_of_day) }
  scope :next_task, -> { where('start_time > ?', Time.current.end_of_day) }
  scope :only_valid, -> { where(is_valid_task: true) } # 有効な予約
  scope :only_invalid, -> { where(is_valid_task: false) } # 無効な予約
  scope :only_appoint, -> { where(is_appoint: true) } # 指名予約
  scope :only_disappoint, -> { where(is_appoint: false) } # 指名予約
  scope :only_from_public, -> { where(is_from_public: true) } # お客様からの予約
  scope :only_from_store, -> { where(is_from_public: false) } # 店舗側での予約
  # ポータルサイト連携用API==============================================
  from = DateTime.current.beginning_of_day
  to = from.since(4.weeks)
  scope :api_tasks, -> { where(start_time: from..to) }

  # UNIXTIMEに変換
  def start_at
    start_time.to_i
  end

  def end_at
    end_time.to_i
  end
  # ==================================================================
  # 予約が被っている時刻に同時に保存されないように検証
  after_create do
    # lockメソッドを使って、DBのトランザクションレベルを変更
    interval_time = calendar.calendar_config.interval_time
    raise TaskUnuniqueError if Task.only_valid.lock.where('start_time < ? && ? < end_time', end_time.since(interval_time.minutes), start_time.ago(interval_time.minutes)).where(staff_id: staff_id).where.not(id: id).any?
  end

  def self.register_unregistered_tasks_in_staff_google_calendar(staff)
    Task.only_valid.future_tasks.staff_tasks(staff).each do |task|
      SyncCalendarService.new(task, task.staff, task.calendar).create_event unless task.google_event_id
    end
  end

  def self.by_calendar(calendar)
    joins(:store_member).where(calendar_id: calendar.id).select('tasks.*, store_members.name, store_members.email, store_members.phone, store_members.id as member_id')
  end

  def calendar_event_uid
    unique_id = "#{staff.calendar.public_uid}todo#{id}"
    Modules::Base32.encode32hex(unique_id).gsub('=', '')
  end

  # その時間の予約に対応できるスタッフがいるかどうかの検証
  def any_staff_available?
    if staff
      return false if invalid?

      return true
    else
      calendar.staffs.each do |staff|
        if staff.google_api_token
          next if SyncCalendarService.new(Task.new, staff, staff.calendar).public_read_event((start_time..end_time)).any?
        end
        self.staff = staff
        if valid?
          self.is_appoint = false
          return true
        end
      end
    end
    return false unless self.staff
  end

  def staff_name
    if is_appoint?
      staff.name
    else
      '指名なし'
    end
  end

  # バリデーション======================================================
  # 時間がかぶっていないかどうか
  def check_time_original
    interval_time = calendar.calendar_config.interval_time
    unless Task.where('start_time < ? && ? < end_time', end_time.since(interval_time.minutes), start_time.ago(interval_time.minutes))
               .where(staff_id: staff_id)
               .where.not(id: id)
               .only_valid
               .empty?
      errors.add(:start_time, '予約時間が重複しています') # エラーメッセージ
    end
  end

  # 勤務時間内かどうか
  def check_include_work_time
    date = start_time.to_date
    staff = self.staff
    shift = staff.staff_shifts.find_by(work_date: date)
    unless shift
      puts 'shiftが存在しません。(指定された日付のshiftは存在しない)'
      raise 'shiftが存在しません。'
    end
    if shift.is_holiday?
      errors.add(:start_time, '①スタッフの勤務時間外です。') # エラーメッセージ
      return
    end
    unless start_time >= shift.work_start_time && end_time <= shift.work_end_time
      errors.add(:start_time, '②スタッフの勤務時間外です。') # エラーメッセージ
      return
    end
    # 休憩時間に被っているかどうか検証
    shift.staff_rest_times.each do |rest|
      if start_time < rest.rest_end_time && end_time > rest.rest_start_time
        errors.add(:start_time, '③スタッフの勤務時間外です。') # エラーメッセージ
        return
      end
    end
  end

  # 開始時間が終了時間より遅くないか
  def start_end_check
    errors.add(:end_time, 'の時間を正しく記入してください。') unless
    start_time < end_time
  end

  # 予約時間が現時刻より先かどうか
  # 過去の予約時間の変更はできない、それ以外は許可
  def check_after_timenow
    errors.add(:start_time, '現時刻より前の予定は作成できません。') if start_time < Time.current && (start_time_changed? || end_time_changed?)
  end

  # 休みの日かどうか
  def check_calendar_holiday
    day = %w[日 月 火 水 木 金 土][start_time.wday]
    if calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day) ||
       calendar.calendar_config.iregular_holidays.where('date >= ?', Date.current).find_by(date: start_time.to_date)
      errors.add(:start_time, 'この日は休みです。')
    end
  end

  private

  def sync_create
    SyncCalendarService.new(self, staff, calendar).create_event
  end

  def sybc_update
    SyncCalendarService.new(self, staff, calendar).update_event
  end

  def sybc_delete
    SyncCalendarService.new(self, staff, calendar).delete_event
  end

  def line_send_with_edit_task
    LineBot.new.push_message_with_edit_task(self, store_member.line_user_id) if store_member.line_user_id
  end

  def line_send_with_delete_task
    LineBot.new.push_message_with_delete_task(self, store_member.line_user_id) if store_member.line_user_id
  end

  def mail_send
    NotificationMailer.send_confirm_to_user(self, calendar.user, calendar).deliver
  end

  def mail_send_with_edit_task
    NotificationMailer.send_edit_task_to_user(self, calendar.user, calendar).deliver
  end

  def mail_send_with_delete_task
    NotificationMailer.send_delete_task_to_user(self, calendar.user, calendar).deliver
  end
end
