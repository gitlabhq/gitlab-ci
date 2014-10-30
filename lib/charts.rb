module Charts
  class Chart
    attr_reader :labels, :total, :success, :builds, :build_times

    def initialize(builds = nil)
      @labels = []
      @total = []
      @success = []
      @build_times = []
      @builds = builds

      collect
    end


    def push(from, to, format)
      @labels << from.strftime(format)
      @total << @builds.where("? > created_at AND created_at > ?", to, from).count
      @success << @builds.where("? > created_at AND created_at > ?", to, from).success.count
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
      builds = @builds.where('builds.finished_at is NOT NULL AND builds.started_at is NOT NULL').last(30)
      builds.each do |build|
        @labels << build.short_sha
        @build_times << (build.duration / 60)
      end
    end
  end

  class GlobalBuildTime < Chart
    def collect
      builds = Build.all.where('builds.finished_at is NOT NULL AND builds.started_at is NOT NULL').last(30)
      builds.each do |build|
        @labels << build.short_sha
        @build_times << (build.duration / 60)
      end
    end
  end

  class GlobalWaitTime < Chart
    def collect
      builds = Build.all.where('builds.started_at is NOT NULL AND builds.created_at is NOT NULL').last(30)
      builds.each do |build|
        @labels << build.short_sha
        @build_times << (build.wait / 60)
      end
    end
  end
end
