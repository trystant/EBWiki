class Hashtag < ActiveRecord::Base
  belongs_to :article

  validate :letters_has_correct_format

  def letters_has_correct_format
    errors.add(:letters, "-- HashTags must start with #") unless letters.start_with?('#')
  end
end
