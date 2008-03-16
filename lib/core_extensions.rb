class Module
  define_method(:deep_const_get) do |str|
    str.split("::").inject(Object) {|a,b| a.const_get(b) } 
  end unless respond_to? :deep_const_get
end 
