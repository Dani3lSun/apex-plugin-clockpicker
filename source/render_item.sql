/*-------------------------------------
 * ClockPicker Functions
 * Version: 1.6.1 (05.03.2016)
 * Author:  Daniel Hochleitner
 *-------------------------------------
*/
FUNCTION render_clockpicker(p_item                IN apex_plugin.t_page_item,
                            p_plugin              IN apex_plugin.t_plugin,
                            p_value               IN VARCHAR2,
                            p_is_readonly         IN BOOLEAN,
                            p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_page_item_render_result IS
  -- plugin attributes
  l_result                  apex_plugin.t_page_item_render_result;
  l_placement               VARCHAR2(50) := p_item.attribute_01;
  l_align                   VARCHAR2(50) := p_item.attribute_02;
  l_autoclose               VARCHAR2(50) := p_item.attribute_03;
  l_done_btn_text           VARCHAR2(100) := p_item.attribute_04;
  l_12h_mode                VARCHAR2(50) := p_item.attribute_05;
  l_suppress_soft_keyboards NUMBER := p_item.attribute_06;
  l_show_clock_button       NUMBER := p_item.attribute_07;
  -- other vars
  l_name            VARCHAR2(30);
  l_escaped_value   VARCHAR2(1000);
  l_onload_string   VARCHAR2(2000);
  l_html_string     VARCHAR2(2000);
  l_element_item_id VARCHAR2(200);
  --
BEGIN
  --
  -- Printer Friendly Display
  IF p_is_printer_friendly THEN
    apex_plugin_util.print_display_only(p_item_name        => p_item.name,
                                        p_display_value    => p_value,
                                        p_show_line_breaks => FALSE,
                                        p_escape           => TRUE,
                                        p_attributes       => p_item.element_attributes);
    -- Read Only Display
  ELSIF p_is_readonly THEN
    apex_plugin_util.print_hidden_if_readonly(p_item_name           => p_item.name,
                                              p_value               => p_value,
                                              p_is_readonly         => p_is_readonly,
                                              p_is_printer_friendly => p_is_printer_friendly);
    -- Normal Display
  ELSE
    --
    l_element_item_id := p_item.name;
    l_name            := apex_plugin.get_input_name_for_page_item(FALSE);
    l_escaped_value   := sys.htf.escape_sc(p_value);
    --
    l_html_string := '<input ';
    l_html_string := l_html_string || 'type="text" ';
    l_html_string := l_html_string || 'name="' || l_name || '" ';
    l_html_string := l_html_string || 'id="' || l_element_item_id || '" ';
    l_html_string := l_html_string || 'value="' || l_escaped_value || '" ';
    l_html_string := l_html_string || 'size="' || p_item.element_width || '" ';
    -- suppress soft keyboard
    IF l_suppress_soft_keyboards = 1 THEN
      l_html_string := l_html_string || 'onfocus="blur();" ';
    END IF;
    --
    l_html_string := l_html_string || 'maxlength="' ||
                     p_item.element_max_length || '" ';
    l_html_string := l_html_string || ' ' || p_item.element_attributes ||
                     ' />';
    -- show clock button
    IF l_show_clock_button = 1 THEN
      l_html_string := l_html_string ||
                       '<a class="a-Button a-Button--popupLOV clockpicker-btn ' ||
                       l_element_item_id ||
                       '_button" href="javascript:void(0);"><span class="fa fa-clock-o"></span></a>';
      -- button style
      apex_css.add(p_css => '.clockpicker-btn { box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.125) inset !important; }',
                   p_key => 'clockpicker_style');
    END IF;
    -- write item html
    htp.p(l_html_string);
    --
    -- Include the Bootstrap CSS
    apex_css.add_file(p_name      => 'bootstrap.min',
                      p_directory => p_plugin.file_prefix || 'css/');
    -- Include the ClockPicker CSS
    apex_css.add_file(p_name      => 'bootstrap-clockpicker.min',
                      p_directory => p_plugin.file_prefix || 'css/');
  
    -- Include ClockPicker JS
    apex_javascript.add_library(p_name           => 'bootstrap-clockpicker.min',
                                p_directory      => p_plugin.file_prefix ||
                                                    'js/',
                                p_version        => NULL,
                                p_skip_extension => FALSE);
    --
    -- JS Inline of the Page
    l_onload_string := 'var ' || l_element_item_id || '_input = $("#' ||
                       l_element_item_id || '").clockpicker({' ||
                       apex_javascript.add_attribute(p_name      => 'placement',
                                                     p_value     => l_placement,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'align',
                                                     p_value     => l_align,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'autoclose',
                                                     p_value     => l_autoclose,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'donetext',
                                                     p_value     => l_done_btn_text,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'twelvehour',
                                                     p_value     => l_12h_mode,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'default',
                                                     p_value     => 'now',
                                                     p_add_comma => FALSE) ||
                       '});' || chr(10);
    -- Button
    IF l_show_clock_button = 1 THEN
      l_onload_string := l_onload_string || '$(".' || l_element_item_id ||
                         '_button").click(function(e){ e.stopPropagation(); ' ||
                         l_element_item_id || '_input.clockpicker("show")' || '})';
    END IF;
    -- Replace true/false quotes
    l_onload_string := REPLACE(REPLACE(l_onload_string,
                                       '"true"',
                                       'true'),
                               '"false"',
                               'false');
    --
    apex_javascript.add_inline_code(p_code => l_onload_string);
    --
  END IF;
  --
  l_result.is_navigable := TRUE;
  --
  RETURN(l_result);
  --
END render_clockpicker;