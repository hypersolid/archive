module ApplicationHelper
  def dots(int)
    r=[]
    s=int.to_s
    gc=s.length/3.0.floor
    gc.times do |i|
      r<<s[s.length-(i+1)*3,3]
    end
    if gc*3<s.length
      r<<s[0,s.length-gc*3]
    end
    r.reverse.join('.')
  end
end
