class BookingsController < ApplicationController
  respond_to :html, :xml, :json
  
  before_action :find_room

  def index
    @bookings = Booking.where("room_id = ? AND end_time >= ?", @room.id, Time.now).order(:start_time)
    respond_with @bookings
  end


  def history
    @bookings = Booking.where("room_id = ? ", @room.id).order(:start_time)
    respond_with @bookings
  end

  def new
    @booking = Booking.new(room_id: @room.id)
  end

  def create
    @booking =  Booking.new(params[:booking].permit(:room_id, :start_time, :length))
    @booking.room = @room
    if @booking.save
      redirect_to room_bookings_path(@room, method: :get)
    else
      render 'new'
    end
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def destroy
    @booking = Booking.find(params[:id]).destroy
    if @booking.destroy
      flash[:notice] = "Booking: #{@booking.start_time.strftime('%e %b %Y %H:%M%p')} to #{@booking.end_time.strftime('%e %b %Y %H:%M%p')} deleted"
      redirect_to room_bookings_path(@room)
    else
      render 'index'
    end
  end

  def edit
    @booking = Booking.find(params[:id])
  end

  def update
    @booking = Booking.find(params[:id])
    # @booking.rooms = @rooms

    if @booking.update(params[:booking].permit(:room_id, :start_time, :length))
      flash[:notice] = 'Your booking was updated succesfully'

      if request.xhr?
        render json: {status: :success}.to_json
      else
        redirect_to room_bookings_path(@room)
      end
    else
      render 'edit'
    end
  end

  private

  def save booking
    if @booking.save
        flash[:notice] = 'booking added'
        redirect_to room_booking_path(@room, @booking)
      else
        render 'new'
      end
  end

  def find_room
    if params[:room_id]
      @room = Room.find_by_id(params[:room_id])
    end
  end

end
