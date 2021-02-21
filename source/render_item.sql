/*-------------------------------------
 * ClockPicker Functions
 * Version: 1.7.0 (22.12.2016)
 * Author:  Daniel Hochleitner
 *
 * Changes:
 * 22.11.2017 Moritz Klein: Change to new interface and enable for interactive Grid
 *-------------------------------------
*/
PROCEDURE render_clockpicker(p_item  in            apex_plugin.t_page_item,
                            p_plugin in            apex_plugin.t_plugin,
                            p_param  in            apex_plugin.t_item_render_param,
                            p_result in out nocopy apex_plugin.t_item_render_result)
IS
  -- plugin attributes
  l_placement               VARCHAR2(50)  := p_item.attribute_01;
  l_align                   VARCHAR2(50)  := p_item.attribute_02;
  l_autoclose               VARCHAR2(50)  := p_item.attribute_03;
  l_done_btn_text           VARCHAR2(100) := p_item.attribute_04;
  l_12h_mode                VARCHAR2(50)  := p_item.attribute_05;
  l_suppress_soft_keyboards NUMBER        := p_item.attribute_06;
  l_show_clock_button       NUMBER        := p_item.attribute_07;
  l_logging                 VARCHAR2(50)  := p_item.attribute_08;
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
  IF p_param.is_printer_friendly THEN
    apex_plugin_util.print_display_only(p_item_name        => p_item.name,
                                        p_display_value    => p_param.value,
                                        p_show_line_breaks => FALSE,
                                        p_escape           => TRUE,
                                        p_attributes       => p_item.element_attributes);
    -- Read Only Display
  ELSIF p_param.is_readonly THEN
    apex_plugin_util.print_hidden_if_readonly(p_item_name           => p_item.name,
                                              p_value               => p_param.value,
                                              p_is_readonly         => p_param.is_readonly,
                                              p_is_printer_friendly => p_param.is_printer_friendly);
    -- Normal Display
  ELSE
    --
    l_element_item_id := p_item.name;
    l_name            := apex_plugin.get_input_name_for_item;
    l_escaped_value   := apex_escape.html(p_param.value);
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
                       '<span class="t-Form-itemText t-Form-itemText--post"><a id="' ||
                       l_element_item_id ||
                       '_button" class="a-Button a-Button--popupLOV clockpicker-btn" href="javascript:void(0);"><span class="fa fa-clock-o"></span></a></span>';
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
    apex_javascript.add_library(p_name           => 'apexclockpicker.min',
                                p_directory      => p_plugin.file_prefix ||
                                                    'js/',
                                p_version        => NULL,
                                p_skip_extension => FALSE);
    --
    -- JS Onload Code
    l_onload_string := 'apexClockPicker.initClockPicker(' ||
                       apex_javascript.add_value(l_element_item_id) || '{' ||
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
                       apex_javascript.add_attribute(p_name      => 'showbutton',
                                                     p_value     => l_show_clock_button,
                                                     p_add_comma => TRUE) ||
                       apex_javascript.add_attribute(p_name      => 'default',
                                                     p_value     => 'now',
                                                     p_add_comma => FALSE) || '},' ||
                       apex_javascript.add_value(l_logging,
                                                 FALSE) || ');';
    --
    apex_javascript.add_inline_code(p_code => l_onload_string);
    --
  END IF;
  --
  p_result.is_navigable := TRUE;
END render_clockpicker;
