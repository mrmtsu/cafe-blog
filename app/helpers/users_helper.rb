module UsersHelper
  def gravatar_for(user, size: 80, cl: "gravatar")
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://getdrawings.com/free-icon-bw/anonymous-avatar-icon-19.png/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: cl)
  end
end
