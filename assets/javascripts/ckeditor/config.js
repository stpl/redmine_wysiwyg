/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.removeButtons = 'Anchor,HorizontalRule';
  config.coreStyles_bold={element:"span",styles:{"font-weight":"bold"}, overrides:"b"};
  config.coreStyles_italic={element:"span", styles:{"font-style":"italic"}, overrides:"i" };
  config.coreStyles_underline={element:"span", styles:{"text-decoration":"underline"}, overrides:"u"};
  config.coreStyles_strike={element:"span", styles:{"text-decoration":"line-through"}, overrides:"s"};
  config.coreStyles_subscript={element:"span", styles:{"vertical-align":"sub"}, overrides:"sub"};
  config.coreStyles_superscript={element:"span", styles:{"vertical-align":"super"}, overrides:"sup"};
};
