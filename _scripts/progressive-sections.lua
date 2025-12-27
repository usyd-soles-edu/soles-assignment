-- Lua filter to inject progressive-sections setting into JavaScript
function Meta(meta)
  -- Get the progressive-sections value from metadata (default to true)
  local enabled = true
  if meta['progressive-sections'] ~= nil then
    enabled = meta['progressive-sections']
  end

  -- Convert to JavaScript boolean
  local js_value = enabled and "true" or "false"

  -- Create script element to inject
  local script = pandoc.RawBlock('html',
    '<script>window.QUARTO_PROGRESSIVE_SECTIONS = ' .. js_value .. ';</script>')

  -- Add to header-includes
  if meta['header-includes'] == nil then
    meta['header-includes'] = pandoc.MetaList{script}
  else
    local header_includes = meta['header-includes']
    if header_includes.t == 'MetaList' then
      table.insert(header_includes, script)
    else
      meta['header-includes'] = pandoc.MetaList{header_includes, script}
    end
  end

  return meta
end
