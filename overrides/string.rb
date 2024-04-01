# frozen_string_literal: true

class String
  def to_time
    DateTime.parse(self).to_time
  end
end
