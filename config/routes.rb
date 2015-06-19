Rails.application.routes.draw do
  root 'courses#index'
  get 'courses/sort' => 'courses#sort'
  get 'benchmarks/sort' => 'benchmarks#sort'
end
