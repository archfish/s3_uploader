class DocsController < ApplicationController
  def new
    @doc = Doc.new
  end
end
