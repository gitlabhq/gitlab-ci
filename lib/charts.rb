module Charts
  class Chart
    attr_reader :labels, :total, :success, :project, :build_times

    def initialize(project)
      @labels = []
      @total = []
      @success = []
      @build_times = []
      @project = project

      collect
    end


    def push(from, to, format)
      @labels << from.strftime(format)
      @total << project.builds.where("? > created_at AND created_at > ?", to, from).count
      @success << project.builds.where("? > created_at AND created_at > ?", to, from).success.count
    end
  end

  class YearChart < Chart
    def collect
      13.times do |i|
        start_month = (Date.today.years_ago(1) + i.month).beginning_of_month
        end_month = start_month.end_of_month

        push(start_month, end_month, "%d %B %Y")
      end
    end
  end

  class MonthChart < Chart
    def collect
      30.times do |i|
        start_day = Date.today - 30.days + i.days
        end_day = Date.today - 30.days + i.day + 1.day

        push(start_day, end_day, "%d %B")
      end
    end
  end

  class WeekChart < Chart
    def collect
      7.times do |i|
        start_day = Date.today - 7.days + i.days
        end_day = Date.today - 7.days + i.day + 1.day

        push(start_day, end_day, "%d %B")
      end
    end
  end

  class BuildTime < Chart
    def collect
      if ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
         sql = "date_part('epoch',finished_at) - date_part('epoch',started_at) as duration"
      else
        sql = 'UNIX_TIMESTAMP(finished_at) - UNIX_TIMESTAMP(started_at) as duration'
      end
      @labels = (1..30).to_a
      @build_times = project.builds.order(:finished_at).limit(30).pluck(sql)
    end
  end
end
