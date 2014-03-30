require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(@req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise Exception if self.already_rendered?
    @res.content_type = type
    @res.body = content
    @already_rendered = true
    @session.store_session(@res) unless @session.nil?
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    raise Exception if self.already_rendered?
    @res.status = 302
    @res["location"] = url
    @already_rendered = true
    @session.store_session(@res) unless @session.nil?
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s
    path_to_template = File.expand_path("./views/#{controller_name.tableize.singularize}/#{template_name}.html.erb")
    content = ERB.new(File.read(path_to_template)).result(binding)

    self.render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session = Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    p name
    self.send(name)
    render(name.to_s) unless self.already_rendered?
  end

end
