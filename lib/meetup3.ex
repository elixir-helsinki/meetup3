defmodule Meetup3 do

  def path_to_file do
    dir = Application.app_dir(:meetup3, "priv")
    Path.join([dir, "top-1m.csv"])
  end
  
end
