-- Lua filter to inject progressive-sections setting into JavaScript
-- and manage script/CSS dependencies properly
--
-- Progressive sections behavior:
-- - The feature is ENABLED by default (no config needed)
-- - The "Guided mode" toggle defaults to OFF (user must enable)
-- - To disable entirely: set `progressive-sections: false` in YAML
-- - User preference persists in localStorage

function Meta(meta)
  -- Only run for HTML output
  if not quarto.doc.is_format("html") then
    return meta
  end

  -- Get the progressive-sections value from metadata (default to true)
  local enabled = true
  if meta['progressive-sections'] ~= nil then
    enabled = meta['progressive-sections']
  end

  -- Convert to JavaScript boolean for config injection
  local js_value = enabled and "true" or "false"

  -- Add the HTML dependency for progressive sections (script + CSS)
  quarto.doc.add_html_dependency({
    name = "progressive-sections",
    version = "1.0.0",
    scripts = {"assets/progressive-sections.js"},
    stylesheets = {"assets/progressive-sections.css"}
  })

  -- Inject the config variable into the head
  local config_script = pandoc.RawBlock('html',
    '<script>window.QUARTO_PROGRESSIVE_SECTIONS = ' .. js_value .. ';</script>')

  if meta['header-includes'] == nil then
    meta['header-includes'] = pandoc.MetaList{config_script}
  else
    local header_includes = meta['header-includes']
    if header_includes.t == 'MetaList' then
      table.insert(header_includes, config_script)
    else
      meta['header-includes'] = pandoc.MetaList{header_includes, config_script}
    end
  end

  return meta
end
