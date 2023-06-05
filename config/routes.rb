# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'urls#index'

  resources :urls, only: %i[index create show], param: :url do
    collection do
      get :last_10
    end
  end
  get ':short_url', to: 'urls#visit', as: :visit

  match '*unmatched', to: 'application#not_found_method', via: :all
end
