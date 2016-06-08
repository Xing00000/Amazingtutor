class WelcomeController < ApplicationController
  before_action :find_language, only: :index

  def mainindex
  end

  def index
    # @teacher = Teacher.all
    # render layout: 'welcome'
    if params[:language_id] && params[:week].blank?
      cookies[:lan] = params[:language_id]
      cookies[:week] = nil
      find_language_teacher

    elsif params[:week] && params[:language_id].blank?
      cookies[:lan] = nil
      cookies[:week] = params[:week]
      find_week_teacher


    elsif params[:week] && params[:language_id]
      cookies[:lan] = params[:language_id]
      cookies[:week] = params[:week]
      find_language_teacher
      @teachera = @teachers
      find_week_teacher
      @teacherb = @teachers
      @teachers = @teachera & @teacherb

    elsif params[:price]
      if cookies[:lan].blank? && cookies[:week].blank?
        find_price_teacher

      elsif cookies[:lan] && cookies[:week].blank?
        find_language_teacher
        @teachera = @teachers
        find_price_teacher
        @teacherb = @teachers
        @teachers = @teachera & @teacherb

      elsif cookies[:lan].blank? && cookies[:week]
        find_week_teacher
        @teachera = @teachers
        find_price_teacher
        @teacherb = @teachers
        @teachers = @teachera & @teacherb

      elsif cookies[:lan] && cookies[:week]
        find_language_teacher
        @teachera = @teachers
        find_week_teacher
        @teacherb = @teachers
        find_price_teacher
        @teacherc = @teachers
        @teachers = @teachera & @teacherb & @teacherc
      end

      respond_to do |format|
        format.js { render 'teacher' }
      end

    elsif params[:week].blank? && params[:language_id].blank?
      cookies[:lan] = nil
      cookies[:week] = nil
      @teachers = Teacher.all
    end

    # @teachers = @teachers.page(params[:page]).per(10)
    #
    # if @teachers.last_page?
    #    @next_page = nil
    # else
    #    @next_page = @teachers.next_page
    # end
  end

  def apply_teacher
  end

  def scholarship
    @encrypted_data = amazing_crypt("encrypt",current_user.email) if current_user
  end

  private

  def find_price_teacher
    @pricefir = params[:price].first.to_i
    @pricesec = params[:price].last.to_i
    @teachers = Teacher.where('ten_fee >= ? AND one_fee <= ?', @pricefir, @pricesec)
    # @teachers = Teacher.where('(ten_fee/10 between ? and ?) AND (one_fee between ? and ?)', @pricefir, @pricesec)
  end

  def find_language_teacher
    @lan_id = cookies[:lan]
    @teachers = Teacher.includes(:teacher_languageships).where(teacher_languageships: { language_id: @lan_id }).uniq
  end

  def find_week_teacher
    @week = cookies[:week].to_i - 1
    @thedaytime = Time.current.utc.at_beginning_of_week + @week.day
    @thedaytimeend = @thedaytime.end_of_day
    if @thedaytime == Time.current.utc.beginning_of_day
      @thedaytime = Time.current.utc+12.hours
      @thedaytimeend = Time.current.utc.end_of_day
      if @thedaytime >= @thedaytimeend
        @thedaytime = @thedaytimeend
      end
    elsif @thedaytime < Time.current.utc
      @thedaytime +=  7.day
      @thedaytimeend = @thedaytime.end_of_day
    end
    @asfront = AvailableSection.select(:start,:end).where('start > ? AND start < ? AND end > ?', @thedaytime, @thedaytimeend,@thedaytimeend)
    @asmid = AvailableSection.select(:start,:end).where('start < ? AND end > ?', @thedaytime, @thedaytimeend)
    @asend = AvailableSection.select(:start,:end).where('end > ? AND end < ? AND start < ?', @thedaytime, @thedaytimeend, @thedaytime)
    @asout = AvailableSection.select(:start,:end).where('start > ? AND end < ?', @thedaytime, @thedaytimeend)
    @as = @asfront.ids + @asmid.ids + @asend.ids + @asout.ids
    @as.uniq
    @teacher_id = AvailableSection.where(id: @as).pluck(:teacher_id).uniq
    @teachers = Teacher.where(id: @teacher_id).uniq
  end

  def find_language
    if params[:language_id]
      @language = Language.find(params[:language_id]).language
    else
      @language = "Teacher also know the ...."
    end
  end

end
