class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :day, :start_hour, :end_hour, :created_at, :updated_at
end
