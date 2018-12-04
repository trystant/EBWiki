# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'maps/index.html.erb', type: :view do
  it 'displays the markers for all the cases' do
    case1 = FactoryBot.create(:case, title: 'John Doe')
    case2 = FactoryBot.create(:case,
                                 title: 'Jimmy Doe',
                                 state: State.where(ansi_code: 'NY').first)
    assign(:cases, Kaminari.paginate_array(
        Case.pluck(:id,
                    :latitude,
                    :longitude,
                    :avatar,
                    :title,
                    :overview)
    ).page(1))
    render
    expect(rendered).to match(/lat":#{case1.latitude},/)
    expect(rendered).to match(/lng":#{case2.longitude}/)
  end
end
