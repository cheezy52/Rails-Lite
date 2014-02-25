require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @already_rendered = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    if already_rendered?
      raise "content already rendered"
    else
      @res.body = content
      @res.content_type = type
      session.store_session(@res)
      @already_built_response = true
    end
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    if already_rendered?
      raise "content already rendered"
    else
      @res["Location"] = url
      @res.status = (302)
      session.store_session(@res)
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raw_template = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")
    template = ERB.new(raw_template)
    content = template.result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def params
    @params
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    render(name) unless already_rendered?
  end
end
