module ApplicationHelper
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def facebook_avatar(user)
    if defined?(current_user) && user == current_user && !session[:auth].blank? && !session[:auth][:info][:image].blank?
      session[:auth][:info][:image]
    else
      user.facebook_image
    end
  end

  def user_foto_url(user = nil)
    return User.new.avatar.to_s if user.class != User
    facebook_avatar(user) || root_url[0..-2] + user.avatar.to_s
  end
  
  def pounds(amount)
    if amount.to_f < 1
      raw "#{(amount*100).to_i}p"
    else
      raw "&pound;#{number_with_precision(amount, :precision => 2)}".sub(/\.00$/, "").sub(/000$/, ",000")
    end
  end

  def score(amount)
    number_with_delimiter amount
  end

  def blob_class(wingman)
    wingman.is_a? Relation ? 'pending' : ''
  end

  def blob_label_class(wingman)
    name = wingman.name || wingman.email || ""
    name.size > 13 ? 'double' : ''
  end

  def header_link_to(title, url)
    if request.fullpath == url
      title
    else
      link_to title, url
    end
  end

  # cost in pounds formatted to match Playspan / Ultimatepay number format
  def cost_pounds(amount)
    amount.to_s.sub(/\.0$/, "")
  end

  def invite_msg
    if Tournament.current.deploy_average_scoring?
      link_to('Invite your brightest friend', '#', :class => 'invite_friend_link') +
      " to replace the game's average score with a better one from them."
    else
      msg = "Invite your brightest friend to become one of your two wingmen, and you get their score added to your"
      msg << " <br/><span class='highlight'>+ 2 free credits straight away</span>" if current_user.can_get_bonus?
      raw msg
    end
  end
end
