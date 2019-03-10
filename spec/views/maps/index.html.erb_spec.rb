# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maps/index.html.erb', type: :view do
  it 'displays all the cases' do
    FactoryBot.create(:case, title: 'John Doe')
    FactoryBot.create(:case,
                      title: 'Jimmy Doe',
                      state: State.where(ansi_code: 'NY').first)
    plucked_cases = Case.pluck(:id,
                               :latitude,
                               :longitude,
                               :avatar,
                               :title,
                               :overview)
    plucked_cases.each do |this_case|
      this_case[3] = Case.find_by_id(this_case[0]).avatar.medium_avatar.to_s
    end
    assign(:cases, Kaminari.paginate_array(plucked_cases).page(1))

    render

    expect(rendered).to match(/EBWiki below maps 2 cases of violence against people of color/m)
  end
end
