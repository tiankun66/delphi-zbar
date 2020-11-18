unit zbar;

interface

{$MINENUMSIZE 4}

uses
  Windows, SysUtils, Classes, Graphics {, dbc, DLL96V1, DLLSP96};

// ------------------------------------------------------------------------
// Copyright 2007-2009 (c) Jeff Brown <spadix@users.sourceforge.net>
//
// This file is part of the ZBar Bar Code Reader.
//
// The ZBar Bar Code Reader is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser Public License as
// published by the Free Software Foundation; either version 2.1 of
// the License, or (at your option) any later version.
//
// The ZBar Bar Code Reader is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser Public License for more details.
//
// You should have received a copy of the GNU Lesser Public License
// along with the ZBar Bar Code Reader; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor,
// Boston, MA  02110-1301  USA
//
// http://sourceforge.net/projects/zbar
// ------------------------------------------------------------------------*/
// Conversion to Delphi Copyright 2009 (c) Stephen Boyd <sboyd@users.sourceforge.net>

// * @file
// ZBar Barcode Reader C API definition
///

// * @mainpage
//
// interface to the barcode reader is available at several levels.
// most applications will want to use the high-level interfaces:
//
// @section high-level High-Level Interfaces
//
// these interfaces wrap all library functionality into an easy-to-use
// package for a specific toolkit:
// - the "GTK+ 2.x widget" may be used with GTK GUI applications.  a
// Python wrapper is included for PyGtk
// - the @ref zbar::QZBar "Qt4 widget" may be used with Qt GUI
// applications
// - the Processor interface (in @ref c-processor "C" or @ref
// zbar::Processor "C++") adds a scanning window to an application
// with no GUI.
//
// @section mid-level Intermediate Interfaces
//
// building blocks used to construct high-level interfaces:
// - the ImageScanner (in @ref c-imagescanner "C" or @ref
// zbar::ImageScanner "C++") looks for barcodes in a library defined
// image object
// - the Window abstraction (in @ref c-window "C" or @ref
// zbar::Window "C++") sinks library images, displaying them on the
// platform display
// - the Video abstraction (in @ref c-video "C" or @ref zbar::Video
// "C++") sources library images from a video device
//
// @section low-level Low-Level Interfaces
//
// direct interaction with barcode scanning and decoding:
// - the Scanner (in @ref c-scanner "C" or @ref zbar::Scanner "C++")
// looks for barcodes in a linear intensity sample stream
// - the Decoder (in @ref c-decoder "C" or @ref zbar::Decoder "C++")
// extracts barcodes from a stream of bar and space widths
///

// * @name Global library interfaces */
// @{*/

// * "color" of element: bar or space. */
type
  zbar_color_e = (ZBAR_SPACE = 0, // *< light area or space between bars */
    ZBAR_BAR = 1                  // *< dark area or colored bar segment */
    );
  zbar_color_t = zbar_color_e;

  // * decoded symbol type. */
type
  zbar_symbol_type_e = (ZBAR_NONE = 0, // *< no symbol decoded */
    ZBAR_PARTIAL = 1,                  // *< intermediate status */
    ZBAR_EAN8 = 8,                     // *< EAN-8 */
    ZBAR_UPCE = 9,                     // *< UPC-E */
    ZBAR_ISBN10 = 10,                  // *< ISBN-10 (from EAN-13). @since 0.4 */
    ZBAR_UPCA = 12,                    // *< UPC-A */
    ZBAR_EAN13 = 13,                   // *< EAN-13 */
    ZBAR_ISBN13 = 14,                  // *< ISBN-13 (from EAN-13). @since 0.4 */
    ZBAR_I25 = 25,                     // *< Interleaved 2 of 5. @since 0.4 */
    ZBAR_CODE39 = 39,                  // *< Code 39. @since 0.4 */
    ZBAR_PDF417 = 57,                  // *< PDF417. @since 0.6 */
    ZBAR_QRCODE = 64, //*< QR Code. @since 0.10 */
    ZBAR_CODE128 = 128                 // *< Code 128 */
  //ZBAR_SYMBOL = $00ff,               // *< mask for base symbol type */
  //ZBAR_ADDON2 = $0200,               // *< 2-digit add-on flag */
  //ZBAR_ADDON5 = $0500,               // *< 5-digit add-on flag */
  //ZBAR_ADDON = $0700                 // *< add-on flag mask */
    );
  zbar_symbol_type_t = zbar_symbol_type_e;

  // * error codes. */
type
  zbar_error_e = (ZBAR_OK = 0, // *< no error */
    ZBAR_ERR_NOMEM,            // *< out of memory */
    ZBAR_ERR_INTERNAL,         // *< internal library error */
    ZBAR_ERR_UNSUPPORTED,      // *< unsupported request */
    ZBAR_ERR_INVALID,          // *< invalid request */
    ZBAR_ERR_SYSTEM,           // *< system error */
    ZBAR_ERR_LOCKING,          // *< locking error */
    ZBAR_ERR_BUSY,             // *< all resources busy */
    ZBAR_ERR_XDISPLAY,         // *< X11 display error */
    ZBAR_ERR_XPROTO,           // *< X11 protocol error */
    ZBAR_ERR_CLOSED,           // *< output window is closed */
    ZBAR_ERR_NUM               // *< number of error codes */
    );
  zbar_error_t = zbar_error_e;

  // * decoder configuration options.
  // @since 0.4
  ///
type
  zbar_config_e = (ZBAR_CFG_ENABLE = 0, // *< enable symbology/feature */
    ZBAR_CFG_ADD_CHECK,                 // *< enable check digit when optional */
    ZBAR_CFG_EMIT_CHECK,                // *< return check digit when present */
    ZBAR_CFG_ASCII,                     // *< enable full ASCII character set */
    ZBAR_CFG_NUM,                       // *< number of boolean configs */

    ZBAR_CFG_MIN_LEN = $20, // *< minimum data length for valid decode */
    ZBAR_CFG_MAX_LEN,       // *< maximum data length for valid decode */

    ZBAR_CFG_X_DENSITY = $100, // *< image scanner vertical scan density */
    ZBAR_CFG_Y_DENSITY         // *< image scanner horizontal scan density */
    );
  zbar_config_t = zbar_config_e;

  // * retrieve runtime library version information.
  // @param major set to the running major version (unless NULL)
  // @param minor set to the running minor version (unless NULL)
  // @returns 0
  ///
function zbar_version(var major: Cardinal; var minor: Cardinal): Integer;

// * set global library debug level.
// @param verbosity desired debug level.  higher values create more spew
///
procedure zbar_set_verbosity(verbosity: Integer);

// * increase global library debug level.
// eg, for -vvvv
///
procedure zbar_increase_verbosity;

// * retrieve string name for symbol encoding.
// @param sym symbol type encoding
// @returns the static string name for the specified symbol type,
// or "UNKNOWN" if the encoding is not recognized
///
function zbar_get_symbol_name(sym: zbar_symbol_type_t): PAnsiChar;

// * retrieve string name for addon encoding.
// @param sym symbol type encoding
// @returns static string name for any addon, or the empty string
// if no addons were decoded
///
function zbar_get_addon_name(sym: zbar_symbol_type_t): PAnsiChar;

// * parse a configuration string of the form "[symbology.]config[=value]".
// the config must match one of the recognized names.
// the symbology, if present, must match one of the recognized names.
// if symbology is unspecified, it will be set to 0.
// if value is unspecified it will be set to 1.
// @returns 0 if the config is parsed successfully, 1 otherwise
// @since 0.4
///
function zbar_parse_config(const config_string: PAnsiChar; var symbology: zbar_symbol_type_t; var config: zbar_config_t;
  var value: Integer): Integer;

// * @internal type unsafe error API (don't use) */
function _zbar_error_spew(objekt: Pointer; verbosity: Integer): Integer;
function _zbar_error_string(objekt: Pointer; verbosity: Integer): PAnsiChar;
function _zbar_get_error_code(objekt: Pointer): zbar_error_t;

// @}*/


// ------------------------------------------------------------*/
// * @name Symbol interface
// decoded barcode symbol result object.  stores type, data, and image
// location of decoded symbol.  all memory is owned by the library
///
// @{*/

type
  zbar_symbol_s = type Pointer;
  // * opaque decoded symbol object. */
  zbar_symbol_t = zbar_symbol_s;

  // * retrieve type of decoded symbol.
  // @returns the symbol type
  ///
function zbar_symbol_get_type(symbol: zbar_symbol_t): zbar_symbol_type_t;

// * retrieve ASCII data decoded from symbol.
// @returns the data string
///
function zbar_symbol_get_data(symbol: zbar_symbol_t): PAnsiChar;
//Function zbar_symbol_get_data_length (symbol: zbar_symbol_t): integer;

// * retrieve current cache count.  when the cache is enabled for the
// image_scanner this provides inter-frame reliability and redundancy
// information for video streams.
// @returns < 0 if symbol is still uncertain.
// @returns 0 if symbol is newly verified.
// @returns > 0 for duplicate symbols
///
function zbar_symbol_get_count(symbol: zbar_symbol_t): Integer;

// * retrieve the number of points in the location polygon.  the
// location polygon defines the image area that the symbol was
// extracted from.
// @returns the number of points in the location polygon
// @note this is currently not a polygon, but the scan locations
// where the symbol was decoded
///
function zbar_symbol_get_loc_size(symbol: zbar_symbol_t): Cardinal;

// * retrieve location polygon x-coordinates.
// points are specified by 0-based index.
// @returns the x-coordinate for a point in the location polygon.
// @returns -1 if index is out of range
///
function zbar_symbol_get_loc_x(symbol: zbar_symbol_t; index: Cardinal): Integer;

// * retrieve location polygon y-coordinates.
// points are specified by 0-based index.
// @returns the y-coordinate for a point in the location polygon.
// @returns -1 if index is out of range
///
function zbar_symbol_get_loc_y(symbol: zbar_symbol_t; index: Cardinal): Integer;

// * iterate the result set.
// @returns the next result symbol, or
// @returns NULL when no more results are available
///
function zbar_symbol_next(symbol: zbar_symbol_t): zbar_symbol_t;

// * print XML symbol element representation to user result buffer.
// @see http://zbar.sourceforge.net/2008/barcode.xsd for the schema.
// @param symbol is the symbol to print
// @param buffer is the inout result pointer, it will be reallocated
// with a larger size if necessary.
// @param buflen is inout length of the result buffer.
// @returns the buffer pointer
// @since 0.6
///
function zbar_symbol_xml(symbol: zbar_symbol_t; var buffer: PAnsiChar; var buflen: Cardinal): PAnsiChar;

// @}*/

// ------------------------------------------------------------*/
// * @name Image interface
// stores image data samples along with associated format and size
// metadata
///
// @{*/

type
  zbar_image_s = type Pointer;
  // * opaque image object. */
  zbar_image_t = zbar_image_s;
  // * cleanup handler callback function.
  // called to free sample data when an image is destroyed.
  ///
  zbar_image_cleanup_handler_t = procedure(image: zbar_image_t); cdecl;
  // * data handler callback function.
  // called when decoded symbol results are available for an image
  ///
  zbar_image_data_handler_t = procedure(image: zbar_image_t; userdata: Pointer); cdecl;

  // * new image constructor.
  // @returns a new image object with uninitialized data and format.
  // this image should be destroyed (using zbar_image_destroy()) as
  // soon as the application is finished with it
  ///
function zbar_image_create: zbar_image_t;

// * image destructor.  all images created by or returned to the
// application should be destroyed using this function.  when an image
// is destroyed, the associated data cleanup handler will be invoked
// if available
// @note make no assumptions about the image or the data buffer.
// they may not be destroyed/cleaned immediately if the library
// is still using them.  if necessary, use the cleanup handler hook
// to keep track of image data buffers
///
procedure zbar_image_destroy(image: zbar_image_t);

// * image reference count manipulation.
// increment the reference count when you store a new reference to the
// image.  decrement when the reference is no longer used.  do not
// refer to the image any longer once the count is decremented.
// zbar_image_ref(image, -1) is the same as zbar_image_destroy(image)
// @since 0.5
///
procedure zbar_image_ref(image: zbar_image_t; refs: Integer);

// * image format conversion.  refer to the documentation for supported
// image formats
// @returns a @em new image with the sample data from the original image
// converted to the requested format.  the original image is
// unaffected.
// @note the converted image size may be rounded (up) due to format
// constraints
///
function zbar_image_convert(image: zbar_image_t; format: PAnsiChar): zbar_image_t;

// * image format conversion with crop/pad.
// if the requested size is larger than the image, the last row/column
// are duplicated to cover the difference.  if the requested size is
// smaller than the image, the extra rows/columns are dropped from the
// right/bottom.
// @returns a @em new image with the sample data from the original
// image converted to the requested format and size.
// @note the image is @em not scaled
// @see zbar_image_convert()
// @since 0.4
///
function zbar_image_convert_resize(image: zbar_image_t; format: PAnsiChar; width: Cardinal; height: Cardinal): zbar_image_t;

// * retrieve the image format.
// @returns the fourcc describing the format of the image sample data
///
function zbar_image_get_format(image: zbar_image_t): Cardinal;

// * retrieve a "sequence" (page/frame) number associated with this image.
// @since 0.6
///
function zbar_image_get_sequence(image: zbar_image_t): Cardinal;

// * retrieve the width of the image.
// @returns the width in sample columns
///
function zbar_image_get_width(image: zbar_image_t): Cardinal;

// * retrieve the height of the image.
// @returns the height in sample rows
///
function zbar_image_get_height(image: zbar_image_t): Cardinal;

// * return the image sample data.  the returned data buffer is only
// valid until zbar_image_destroy() is called
///
function zbar_image_get_data(image: zbar_image_t): Pointer;

// * return the size of image data.
// @since 0.6
///
function zbar_image_get_data_length(img: zbar_image_t): Cardinal;

// * image_scanner decode result iterator.
// @returns the first decoded symbol result for an image
// or NULL if no results are available
///
function zbar_image_first_symbol(image: zbar_image_t): zbar_symbol_t;

// * specify the fourcc image format code for image sample data.
// refer to the documentation for supported formats.
// @note this does not convert the data!
// (see zbar_image_convert() for that)
///
procedure zbar_image_set_format(image: zbar_image_t; format: PAnsiChar);

// * associate a "sequence" (page/frame) number with this image.
// @since 0.6
///
procedure zbar_image_set_sequence(image: zbar_image_t; sequence_num: Cardinal);

// * specify the pixel size of the image.
// @note this does not affect the data!
///
procedure zbar_image_set_size(image: zbar_image_t; width: Cardinal; height: Cardinal);

// * specify image sample data.  when image data is no longer needed by
// the library the specific data cleanup handler will be called
// (unless NULL)
// @note application image data will not be modified by the library
///
procedure zbar_image_set_data(image: zbar_image_t; data: Pointer; data_byte_length: Cardinal;
  cleanup_hndlr: zbar_image_cleanup_handler_t);

// * built-in cleanup handler.
// passes the image data buffer to free()
///
procedure zbar_image_free_data(image: zbar_image_t);

// * associate user specified data value with an image.
// @since 0.5
///
procedure zbar_image_set_userdata(image: zbar_image_t; userdata: Pointer);

// * return user specified data value associated with the image.
// @since 0.5
///
function zbar_image_get_userdata(image: zbar_image_t): Pointer;

// * dump raw image data to a file for debug.
// the data will be prefixed with a 16 byte header consisting of:
// - 4 bytes uint = 0x676d697a ("zimg")
// - 4 bytes format fourcc
// - 2 bytes width
// - 2 bytes height
// - 4 bytes size of following image data in bytes
// this header can be dumped w/eg:
// @verbatim
// od -Ax -tx1z -N16 -w4 [file]
// @endverbatim
// for some formats the image can be displayed/converted using
// ImageMagick, eg:
// @verbatim
// display -size 640x480+16 [-depth ?] [-sampling-factor ?x?] \
// {GRAY,RGB,UYVY,YUV}:[file]
// @endverbatim
//
// @param image the image object to dump
// @param filebase base filename, appended with ".XXXX.zimg" where
// XXXX is the format fourcc
// @returns 0 on success or a system error code on failure
///
function zbar_image_write(image: zbar_image_t; filebase: PAnsiChar): Integer;

// * read back an image in the format written by zbar_image_write()
// @note TBD
///
function zbar_image_read(filename: PAnsiChar): zbar_image_t;

// @}*/
// *------------------------------------------------------------*/
// * @name Processor interface
// @anchor c-processor
// high-level self-contained image processor.
// processes video and images for barcodes, optionally displaying
// images to a library owned output window
///
// @{*/

type
  zbar_processor_s = type Pointer;
  // * opaque standalone processor object. */
  zbar_processor_t = zbar_processor_s;

  // * constructor.
  // if threaded is set and threading is available the processor
  // will spawn threads where appropriate to avoid blocking and
  // improve responsiveness
  ///
function zbar_processor_create(threaded: Integer): zbar_processor_t;

// * destructor.  cleans up all resources associated with the processor
///
procedure zbar_processor_destroy(processor: zbar_processor_t);

// * (re)initialization.
// opens a video input device and/or prepares to display output
///
function zbar_processor_init(processor: zbar_processor_t; video_device: PAnsiChar; enable_display: Integer): Integer;

// * request a preferred size for the video image from the device.
// the request may be adjusted or completely ignored by the driver.
// @note must be called before zbar_processor_init()
// @since 0.6
///
function zbar_processor_request_size(processor: zbar_processor_t; width: Cardinal; height: Cardinal): Integer;

// * request a preferred video driver interface version for
// debug/testing.
// @note must be called before zbar_processor_init()
// @since 0.6
///
function zbar_processor_request_interface(processor: zbar_processor_t; version: Integer): Integer;

// * request a preferred video I/O mode for debug/testing.  You will
// get errors if the driver does not support the specified mode.
// @verbatim
// 0 = auto-detect
// 1 = force I/O using read()
// 2 = force memory mapped I/O using mmap()
// 3 = force USERPTR I/O (v4l2 only)
// @endverbatim
// @note must be called before zbar_processor_init()
// @since 0.7
///
function zbar_processor_request_iomode(video: zbar_processor_t; iomode: Integer): Integer;

// * force specific input and output formats for debug/testing.
// @note must be called before zbar_processor_init()
///
function zbar_processor_force_format(processor: zbar_processor_t; input_format: Cardinal;
  output_format: Cardinal): Integer;

// * setup result handler callback.
// the specified function will be called by the processor whenever
// new results are available from the video stream or a static image.
// pass a NULL value to disable callbacks.
// @param processor the object on which to set the handler.
// @param handler the function to call when new results are available.
// @param userdata is set as with zbar_processor_set_userdata().
// @returns the previously registered handler
///
function zbar_processor_set_data_handler(processor: zbar_processor_t; handler: zbar_image_data_handler_t;
  userdata: PAnsiChar): zbar_image_data_handler_t;

// * associate user specified data value with the processor.
// @since 0.6
///
procedure zbar_processor_set_userdata(processor: zbar_processor_t; userdata: Pointer);

// * return user specified data value associated with the processor.
// @since 0.6
///
function zbar_processor_get_userdata(processor: zbar_processor_t): Pointer;

// * set config for indicated symbology (0 for all) to specified value.
// @returns 0 for success, non-0 for failure (config does not apply to
// specified symbology, or value out of range)
// @see zbar_decoder_set_config()
// @since 0.4
///
function zbar_processor_set_config(processor: zbar_processor_t; symbology: zbar_symbol_type_t; config: zbar_config_t;
  value: Integer): Integer;

// * parse configuration string using zbar_parse_config()
// and apply to processor using zbar_processor_set_config().
// @returns 0 for success, non-0 for failure
// @see zbar_parse_config()
// @see zbar_processor_set_config()
// @since 0.4
///
function zbar_processor_parse_config(processor: zbar_processor_t; config_string: PAnsiChar): Integer;

// * retrieve the current state of the ouput window.
// @returns 1 if the output window is currently displayed, 0 if not.
// @returns -1 if an error occurs
///
function zbar_processor_is_visible(processor: zbar_processor_t): Integer;

// * show or hide the display window owned by the library.
// the size will be adjusted to the input size
///
function zbar_processor_set_visible(processor: zbar_processor_t; visible: Integer): Integer;

// * control the processor in free running video mode.
// only works if video input is initialized. if threading is in use,
// scanning will occur in the background, otherwise this is only
// useful wrapping calls to zbar_processor_user_wait(). if the
// library output window is visible, video display will be enabled.
///
function zbar_processor_set_active(processor: zbar_processor_t; active: Integer): Integer;

// * wait for input to the display window from the user
// (via mouse or keyboard).
// @returns >0 when input is received, 0 if timeout ms expired
// with no input or -1 in case of an error
///
function zbar_processor_user_wait(processor: zbar_processor_t; timeout: Integer): Integer;

// * process from the video stream until a result is available,
// or the timeout (in milliseconds) expires.
// specify a timeout of -1 to scan indefinitely
// (zbar_processor_set_active() may still be used to abort the scan
// from another thread).
// if the library window is visible, video display will be enabled.
// @note that multiple results may still be returned (despite the
// name).
// @returns >0 if symbols were successfully decoded,
// 0 if no symbols were found (ie, the timeout expired)
// or -1 if an error occurs
///
function zbar_process_one(processor: zbar_processor_t; timeout: Integer): Integer;

// * process the provided image for barcodes.
// if the library window is visible, the image will be displayed.
// @returns >0 if symbols were successfully decoded,
// 0 if no symbols were found or -1 if an error occurs
///
function zbar_process_image(processor: zbar_processor_t; image: zbar_image_t): Integer;

// * display detail for last processor error to stderr.
// @returns a non-zero value suitable for passing to exit()
///
function zbar_processor_error_spew(processor: zbar_processor_t; verbosity: Integer): Integer;

// * retrieve the detail string for the last processor error. */
function zbar_processor_error_string(processor: zbar_processor_t; verbosity: Integer): PAnsiChar;

// * retrieve the type code for the last processor error. */
function zbar_processor_get_error_code(processor: zbar_processor_t): zbar_error_t;

// @}*/

// ------------------------------------------------------------*/
// * @name Video interface
// @anchor c-video
// mid-level video source abstraction.
// captures images from a video device
///
// @{*/

type
  zbar_video_s = type Pointer;
  // * opaque video object. */
  zbar_video_t = zbar_video_s;

  // * constructor. */
function zbar_video_create: zbar_video_t;

// * destructor. */
procedure zbar_video_destroy(video: zbar_video_t);

// * open and probe a video device.
// the device specified by platform specific unique name
// (v4l device node path in *nix eg "/dev/video",
// DirectShow DevicePath property in windows).
// @returns 0 if successful or -1 if an error occurs
///
function zbar_video_open(video: zbar_video_t; device: PAnsiChar): Integer;

// * retrieve file descriptor associated with open *nix video device
// useful for using select()/poll() to tell when new images are
// available (NB v4l2 only!!).
// @returns the file descriptor or -1 if the video device is not open
// or the driver only supports v4l1
///
function zbar_video_get_fd(video: zbar_video_t): Integer;

// * request a preferred size for the video image from the device.
// the request may be adjusted or completely ignored by the driver.
// @returns 0 if successful or -1 if the video device is already
// initialized
// @since 0.6
///
function zbar_video_request_size(video: zbar_video_t; width: Cardinal; height: Cardinal): Integer;

// * request a preferred driver interface version for debug/testing.
// @note must be called before zbar_video_open()
// @since 0.6
///
function zbar_video_request_interface(video: zbar_video_t; version: Integer): Integer;

// * request a preferred I/O mode for debug/testing.  You will get
// errors if the driver does not support the specified mode.
// @verbatim
// 0 = auto-detect
// 1 = force I/O using read()
// 2 = force memory mapped I/O using mmap()
// 3 = force USERPTR I/O (v4l2 only)
// @endverbatim
// @note must be called before zbar_video_open()
// @since 0.7
///
function zbar_video_request_iomode(video: zbar_video_t; iomode: Integer): Integer;

// * retrieve current output image width.
// @returns the width or 0 if the video device is not open
///
function zbar_video_get_width(video: zbar_video_t): Integer;

// * retrieve current output image height.
// @returns the height or 0 if the video device is not open
///
function zbar_video_get_height(video: zbar_video_t): Integer;

// * initialize video using a specific format for debug.
// use zbar_negotiate_format() to automatically select and initialize
// the best available format
///
function zbar_video_init(video: zbar_video_t; format: Cardinal): Integer;

// * start/stop video capture.
// all buffered images are retired when capture is disabled.
// @returns 0 if successful or -1 if an error occurs
///
function zbar_video_enable(video: zbar_video_t; enable: Integer): Integer;

// * retrieve next captured image.  blocks until an image is available.
// @returns NULL if video is not enabled or an error occurs
///
function zbar_video_next_image(video: zbar_video_t): zbar_image_t;

// * display detail for last video error to stderr.
// @returns a non-zero value suitable for passing to exit()
///
function zbar_video_error_spew(video: zbar_video_t; verbosity: Integer): Integer;

// * retrieve the detail string for the last video error. */
function zbar_video_error_string(video: zbar_video_t; verbosity: Integer): PAnsiChar;

// * retrieve the type code for the last video error. */
function zbar_video_get_error_code(video: zbar_video_t): zbar_error_t;

// @}*/

// ------------------------------------------------------------*/
// * @name Window interface
// @anchor c-window
// mid-level output window abstraction.
// displays images to user-specified platform specific output window
///
// @{*/

type
  zbar_window_s = type Pointer;
  // * opaque window object. */
  zbar_window_t = zbar_window_s;

  // * constructor. */
function zbar_window_create: zbar_window_t;

// * destructor. */
procedure zbar_window_destroy(window: zbar_window_t);

// * associate reader with an existing platform window.
// This can be any "Drawable" for X Windows or a "HWND" for windows.
// input images will be scaled into the output window.
// pass NULL to detach from the resource, further input will be
// ignored
///
function zbar_window_attach(window: zbar_window_t; x11_display_w32_hwnd: Pointer; x11_drawable: Cardinal): Integer;

// * control content level of the reader overlay.
// the overlay displays graphical data for informational or debug
// purposes.  higher values increase the level of annotation (possibly
// decreasing performance). @verbatim
// 0 = disable overlay
// 1 = outline decoded symbols (default)
// 2 = also track and display input frame rate
// @endverbatim
///
procedure zbar_window_set_overlay(window: zbar_window_t; level: Integer);

// * draw a new image into the output window. */
function zbar_window_draw(window: zbar_window_t; image: zbar_image_t): Integer;

// * redraw the last image (exposure handler). */
function zbar_window_redraw(window: zbar_window_t): Integer;

// * resize the image window (reconfigure handler).
// this does @em not update the contents of the window
// @since 0.3, changed in 0.4 to not redraw window
///
function zbar_window_resize(window: zbar_window_t; width: Cardinal; height: Cardinal): Integer;

// * display detail for last window error to stderr.
// @returns a non-zero value suitable for passing to exit()
///
function zbar_window_error_spew(window: zbar_window_t; verbosity: Integer): Integer;

// * retrieve the detail string for the last window error. */
function zbar_window_error_string(window: zbar_window_t; verbosity: Integer): PAnsiChar;

// * retrieve the type code for the last window error. */
function zbar_window_get_error_code(window: zbar_window_t): zbar_error_t;

// * select a compatible format between video input and output window.
// the selection algorithm attempts to use a format shared by
// video input and window output which is also most useful for
// barcode scanning.  if a format conversion is necessary, it will
// heuristically attempt to minimize the cost of the conversion
///
function zbar_negotiate_format(video: zbar_video_t; window: zbar_window_t): Integer;

// @}*/

// ------------------------------------------------------------*/
// * @name Image Scanner interface
// @anchor c-imagescanner
// mid-level image scanner interface.
// reads barcodes from 2-D images
///
// @{*/

type
  zbar_image_scanner_s = type Pointer;
  // * opaque image scanner object. */
  zbar_image_scanner_t = zbar_image_scanner_s;

  // * constructor. */
function zbar_image_scanner_create: zbar_image_scanner_t;

// * destructor. */
procedure zbar_image_scanner_destroy(scanner: zbar_image_scanner_t);

// * setup result handler callback.
// the specified function will be called by the scanner whenever
// new results are available from a decoded image.
// pass a NULL value to disable callbacks.
// @returns the previously registered handler
///
function zbar_image_scanner_set_data_handler(scanner: zbar_image_scanner_t; handler: zbar_image_data_handler_t;
  userdata: Pointer): zbar_image_data_handler_t;

// * set config for indicated symbology (0 for all) to specified value.
// @returns 0 for success, non-0 for failure (config does not apply to
// specified symbology, or value out of range)
// @see zbar_decoder_set_config()
// @since 0.4
///
function zbar_image_scanner_set_config(scanner: zbar_image_scanner_t; symbology: zbar_symbol_type_t;
  config: zbar_config_t; value: Integer): Integer;

// * parse configuration string using zbar_parse_config()
// and apply to image scanner using zbar_image_scanner_set_config().
// @returns 0 for success, non-0 for failure
// @see zbar_parse_config()
// @see zbar_image_scanner_set_config()
// @since 0.4
///
function zbar_image_scanner_parse_config(scanner: zbar_image_scanner_t; config_string: PAnsiChar): Integer;

// * enable or disable the inter-image result cache (default disabled).
// mostly useful for scanning video frames, the cache filters
// duplicate results from consecutive images, while adding some
// consistency checking and hysteresis to the results.
// this interface also clears the cache
///
procedure zbar_image_scanner_enable_cache(scanner: zbar_image_scanner_t; enable: Integer);

// * scan for symbols in provided image.
// @returns >0 if symbols were successfully decoded from the image,
// 0 if no symbols were found or -1 if an error occurs
///
function zbar_scan_image(scanner: zbar_image_scanner_t; image: zbar_image_t): Integer;

// @}*/

// ------------------------------------------------------------*/
// * @name Decoder interface
// @anchor c-decoder
// low-level bar width stream decoder interface.
// identifies symbols and extracts encoded data
///
// @{*/

type
  zbar_decoder_s = type Pointer;
  // * opaque decoder object. */
  zbar_decoder_t = zbar_decoder_s;

  // * decoder data handler callback function.
  // called by decoder when new data has just been decoded
  ///
  zbar_decoder_handler_t = procedure(decoder: zbar_decoder_t);

  // * constructor. */
function zbar_decoder_create: zbar_decoder_t;

// * destructor. */
procedure zbar_decoder_destroy(decoder: zbar_decoder_t);

// * set config for indicated symbology (0 for all) to specified value.
// @returns 0 for success, non-0 for failure (config does not apply to
// specified symbology, or value out of range)
// @since 0.4
///
function zbar_decoder_set_config(decoder: zbar_decoder_t; symbology: zbar_symbol_type_t; config: zbar_config_t;
  value: Integer): Integer;

// * parse configuration string using zbar_parse_config()
// and apply to decoder using zbar_decoder_set_config().
// @returns 0 for success, non-0 for failure
// @see zbar_parse_config()
// @see zbar_decoder_set_config()
// @since 0.4
///
function zbar_decoder_parse_config(decoder: zbar_decoder_t; config_string: PAnsiChar): Integer;

// * clear all decoder state.
// any partial symbols are flushed
///
procedure zbar_decoder_reset(decoder: zbar_decoder_t);

// * mark start of a new scan pass.
// clears any intra-symbol state and resets color to ::ZBAR_SPACE.
// any partially decoded symbol state is retained
///
procedure zbar_decoder_new_scan(decoder: zbar_decoder_t);

// * process next bar/space width from input stream.
// the width is in arbitrary relative units.  first value of a scan
// is ::ZBAR_SPACE width, alternating from there.
// @returns appropriate symbol type if width completes
// decode of a symbol (data is available for retrieval)
// @returns ::ZBAR_PARTIAL as a hint if part of a symbol was decoded
// @returns ::ZBAR_NONE (0) if no new symbol data is available
///
function zbar_decode_width(decoder: zbar_decoder_t; width: Cardinal): zbar_symbol_type_t;

// * retrieve color of @em next element passed to
// zbar_decode_width(). */
function zbar_decoder_get_color(decoder: zbar_decoder_t): zbar_color_t;

// * retrieve last decoded data in ASCII format.
// @returns the data string or NULL if no new data available.
// the returned data buffer is owned by library, contents are only
// valid between non-0 return from zbar_decode_width and next library
// call
///
function zbar_decoder_get_data(decoder: zbar_decoder_t): PAnsiChar;

// * retrieve last decoded symbol type.
// @returns the type or ::ZBAR_NONE if no new data available
///
function zbar_decoder_get_type(decoder: zbar_decoder_t): zbar_symbol_type_t;

// * setup data handler callback.
// the registered function will be called by the decoder
// just before zbar_decode_width() returns a non-zero value.
// pass a NULL value to disable callbacks.
// @returns the previously registered handler
///
function zbar_decoder_set_handler(decoder: zbar_decoder_t; handler: zbar_decoder_handler_t): zbar_decoder_handler_t;

// * associate user specified data value with the decoder. */
procedure zbar_decoder_set_userdata(decoder: zbar_decoder_t; userdata: Pointer);

// * return user specified data value associated with the decoder. */
function zbar_decoder_get_userdata(decoder: zbar_decoder_t): Pointer;

// @}*/

// ------------------------------------------------------------*/
// * @name Scanner interface
// @anchor c-scanner
// low-level linear intensity sample stream scanner interface.
// identifies "bar" edges and measures width between them.
// optionally passes to bar width decoder
///
// @{*/

type
  zbar_scanner_s = type Pointer;
  // * opaque scanner object. */
  zbar_scanner_t = zbar_scanner_s;

  // * constructor.
  // if decoder is non-NULL it will be attached to scanner
  // and called automatically at each new edge
  // current color is initialized to ::ZBAR_SPACE
  // (so an initial BAR->SPACE transition may be discarded)
  ///
function zbar_scanner_create(decoder: zbar_decoder_t): zbar_scanner_t;

// * destructor. */
procedure zbar_scanner_destroy(scanner: zbar_scanner_t);

// * clear all scanner state.
// also resets an associated decoder
///
function zbar_scanner_reset(scanner: zbar_scanner_t): zbar_symbol_type_t;

// * mark start of a new scan pass. resets color to ::ZBAR_SPACE.
// also updates an associated decoder.
// @returns any decode results flushed from the pipeline
// @note when not using callback handlers, the return value should
// be checked the same as zbar_scan_y()
///
function zbar_scanner_new_scan(scanner: zbar_scanner_t): zbar_symbol_type_t;

// * process next sample intensity value.
// intensity (y) is in arbitrary relative units.
// @returns result of zbar_decode_width() if a decoder is attached,
// otherwise @returns (::ZBAR_PARTIAL) when new edge is detected
// or 0 (::ZBAR_NONE) if no new edge is detected
///
function zbar_scan_y(scanner: zbar_scanner_t; y: Integer): zbar_symbol_type_t;

// * process next sample from RGB (or BGR) triple. */
function zbar_scan_rgb24(scanner: zbar_scanner_t; rgb: PAnsiChar): zbar_symbol_type_t;

// * retrieve last scanned width. */
function zbar_scanner_get_width(scanner: zbar_scanner_t): Cardinal;

// * retrieve last scanned color. */
function zbar_scanner_get_color(scanner: zbar_scanner_t): zbar_color_t;

// Returns True if the ZBAR dll has been found and loaded
function zbar_loaded: Boolean;

// A table to equate bar code type enum values to descriptive names
type
  TZbarBarcodeRecord = record
    BCCode: zbar_symbol_type_e;
    BCName: AnsiString;
  end;

{const
  ZBAR_BARCODES: array [0 .. 9] of TZbarBarcodeRecord = ((BCCode: ZBAR_EAN8; BCName: 'EAN-8'), (BCCode: ZBAR_UPCE;
      BCName: 'UPCE'), (BCCode: ZBAR_ISBN10; BCName: 'ISBN-10'), (BCCode: ZBAR_UPCA; BCName: 'UPCA'),
    (BCCode: ZBAR_EAN13; BCName: 'EAN-13'), (BCCode: ZBAR_ISBN13; BCName: 'ISBN-13'), (BCCode: ZBAR_I25;
      BCName: 'Interleaved 2 0f 5'), (BCCode: ZBAR_CODE39; BCName: 'Code39'), (BCCode: ZBAR_PDF417; BCName: 'PDF417'),
    (BCCode: ZBAR_CODE128; BCName: 'Code128'));          }
const
  ZBAR_BARCODES: array[0..10] of TZbarBarcodeRecord = (
    (BCCode: ZBAR_EAN8; BCName: 'EAN-8'),
    (BCCode: ZBAR_UPCE; BCName: 'UPCE'),
    (BCCode: ZBAR_ISBN10; BCName: 'ISBN-10'),
    (BCCode: ZBAR_UPCA; BCName: 'UPCA'),
    (BCCode: ZBAR_EAN13; BCName: 'EAN-13'),
    (BCCode: ZBAR_ISBN13; BCName: 'ISBN-13'),
    (BCCode: ZBAR_I25; BCName: 'Interleaved 2 0f 5'),
    (BCCode: ZBAR_CODE39; BCName: 'Code39'),
    (BCCode: ZBAR_PDF417; BCName: 'PDF417'),
    (BCCode: ZBAR_CODE128; BCName: 'Code128'),
    (BCCode: ZBAR_QRCODE; BCName: 'QR')
    );

implementation

var
  DllHandle: THandle;

procedure GetAddressOf(procName: AnsiString; var procPtr: Pointer);
begin
  if (DllHandle = 0) then
    raise Exception.Create('libzbar-0.dll not found');
  procPtr := GetProcAddress(DllHandle, PAnsiChar(procName));
  if (not Assigned(procPtr)) then
    raise Exception.CreateFmt('Entry point %s not found in libzbar-0.dll', [procName]);
end;

function zbar_loaded: Boolean;
begin
  Result := DllHandle <> 0;
end;

function zbar_version(var major: Cardinal; var minor: Cardinal): Integer;
var
  proc: function(var major: Cardinal; var minor: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_version', @proc);
  Result := proc(major, minor);
end;

procedure zbar_set_verbosity(verbosity: Integer);
var
  proc: procedure(verbosity: Integer); cdecl;
begin
  GetAddressOf('zbar_set_verbosity', @proc);
  proc(verbosity);
end;

procedure zbar_increase_verbosity;
var
  proc: procedure; cdecl;
begin
  GetAddressOf('zbar_increase_verbosity', @proc);
  proc;
end;

function zbar_get_symbol_name(sym: zbar_symbol_type_t): PAnsiChar;
var
  proc: function(sym: zbar_symbol_type_t): PAnsiChar; cdecl;
begin
  GetAddressOf('zbar_get_symbol_name', @proc);
  Result := proc(sym);
end;

function zbar_get_addon_name(sym: zbar_symbol_type_t): PAnsiChar;
var
  proc: function(sym: zbar_symbol_type_t): PAnsiChar; cdecl;
begin
  GetAddressOf('zbar_get_addon_name', @proc);
  Result := proc(sym);
end;

function zbar_parse_config(const config_string: PAnsiChar; var symbology: zbar_symbol_type_t; var config: zbar_config_t;
  var value: Integer): Integer;
var
  proc: function(const config_string: PAnsiChar; var symbology: zbar_symbol_type_t; var config: zbar_config_t;
    var value: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_parse_config', @proc);
  Result := proc(config_string, symbology, config, value);
end;

function _zbar_error_spew(objekt: Pointer; verbosity: Integer): Integer;
var
  proc: function(objekt: Pointer; verbosity: Integer): Integer; cdecl;
begin
  GetAddressOf('_zbar_error_spew', @proc);
  Result := proc(objekt, verbosity);
end;

function _zbar_error_string(objekt: Pointer; verbosity: Integer): PAnsiChar;
var
  proc: function(objekt: Pointer; verbosity: Integer): PAnsiChar; cdecl;
begin
  GetAddressOf('_zbar_error_string', @proc);
  Result := proc(objekt, verbosity);
end;

function _zbar_get_error_code(objekt: Pointer): zbar_error_t;
var
  proc: function(objekt: Pointer): zbar_error_t; cdecl;
begin
  GetAddressOf('_zbar_get_error_code', @proc);
  Result := proc(objekt);
end;

function zbar_symbol_get_type(symbol: zbar_symbol_t): zbar_symbol_type_t;
var
  proc: function(symbol: zbar_symbol_t): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_symbol_get_type', @proc);
  Result := proc(symbol);
end;

{Function zbar_symbol_get_data_length (symbol: zbar_symbol_t): integer;
var
  proc: function(symbol: zbar_symbol_t): integer; cdecl;
begin
  GetAddressOf('zbar_symbol_get_type', @proc);
  Result := proc(symbol.datalen);
end; }



function zbar_symbol_get_data(symbol: zbar_symbol_t): PAnsiChar;
var
  proc: function(symbol: zbar_symbol_t): PAnsiChar; cdecl;
begin
  GetAddressOf('zbar_symbol_get_data', @proc);
  Result := proc(symbol);
end;

function zbar_symbol_get_count(symbol: zbar_symbol_t): Integer;
var
  proc: function(symbol: zbar_symbol_t): Integer; cdecl;
begin
  GetAddressOf('zbar_symbol_get_count', @proc);
  Result := proc(symbol);
end;

function zbar_symbol_get_loc_size(symbol: zbar_symbol_t): Cardinal;
var
  proc: function(symbol: zbar_symbol_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_symbol_get_loc_size', @proc);
  Result := proc(symbol);
end;

function zbar_symbol_get_loc_x(symbol: zbar_symbol_t; index: Cardinal): Integer;
var
  proc: function(symbol: zbar_symbol_t; index: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_symbol_get_loc_x', @proc);
  Result := proc(symbol, index);
end;

function zbar_symbol_get_loc_y(symbol: zbar_symbol_t; index: Cardinal): Integer;
var
  proc: function(symbol: zbar_symbol_t; index: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_symbol_get_loc_y', @proc);
  Result := proc(symbol, index);
end;

function zbar_symbol_next(symbol: zbar_symbol_t): zbar_symbol_t;
var
  proc: function(symbol: zbar_symbol_t): zbar_symbol_t; cdecl;
begin
  GetAddressOf('zbar_symbol_next', @proc);
  Result := proc(symbol);
end;

function zbar_symbol_xml(symbol: zbar_symbol_t; var buffer: PAnsiChar; var buflen: Cardinal): PAnsiChar;
var
  proc: function(symbol: zbar_symbol_t; var buffer: PAnsiChar; var buflen: Cardinal): PAnsiChar; cdecl;
begin
  GetAddressOf('zbar_symbol_xml', @proc);
  Result := proc(symbol, buffer, buflen);
end;

function zbar_image_create: zbar_image_t;
var
  proc: function: zbar_image_t; cdecl;
begin
  GetAddressOf('zbar_image_create', @proc);
  Result := proc;
end;

procedure zbar_image_destroy(image: zbar_image_t);
var
  proc: procedure(image: zbar_image_t); cdecl;
begin
  GetAddressOf('zbar_image_destroy', @proc);
  proc(image);
end;

procedure zbar_image_ref(image: zbar_image_t; refs: Integer);
var
  proc: procedure(image: zbar_image_t; refs: Integer); cdecl;
begin
  GetAddressOf('zbar_image_ref', @proc);
  proc(image, refs);
end;

function zbar_image_convert(image: zbar_image_t; format: PAnsiChar): zbar_image_t;
var
  proc: function(image: zbar_image_t; format: Cardinal): zbar_image_t; cdecl;
var
  val: Cardinal;
begin
  GetAddressOf('zbar_image_convert', @proc);
  val    := PCardinal(format)^;
  Result := proc(image, val);
end;

function zbar_image_convert_resize(image: zbar_image_t; format: PAnsiChar; width: Cardinal; height: Cardinal): zbar_image_t;
var
  proc: function(image: zbar_image_t; format: Cardinal; width: Cardinal; height: Cardinal): zbar_image_t; cdecl;
var
  val: Cardinal;
begin
  GetAddressOf('zbar_image_convert_resize', @proc);
  val    := PCardinal(format)^;
  Result := proc(image, val, width, height);
end;

function zbar_image_get_format(image: zbar_image_t): Cardinal;
var
  proc: function(image: zbar_image_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_image_get_format', @proc);
  Result := proc(image);
end;

function zbar_image_get_sequence(image: zbar_image_t): Cardinal;
var
  proc: function(image: zbar_image_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_image_get_sequence', @proc);
  Result := proc(image);
end;

function zbar_image_get_width(image: zbar_image_t): Cardinal;
var
  proc: function(image: zbar_image_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_image_get_width', @proc);
  Result := proc(image);
end;

function zbar_image_get_height(image: zbar_image_t): Cardinal;
var
  proc: function(image: zbar_image_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_image_get_height', @proc);
  Result := proc(image);
end;

function zbar_image_get_data(image: zbar_image_t): Pointer;
var
  proc: function(image: zbar_image_t): Pointer; cdecl;
begin
  GetAddressOf('zbar_image_get_data', @proc);
  Result := proc(image);
end;

function zbar_image_get_data_length(img: zbar_image_t): Cardinal;
var
  proc: function(img: zbar_image_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_image_get_data_length', @proc);
  Result := proc(img);
end;

function zbar_image_first_symbol(image: zbar_image_t): zbar_symbol_t;
var
  proc: function(image: zbar_image_t): zbar_symbol_t; cdecl;
begin
  GetAddressOf('zbar_image_first_symbol', @proc);
  Result := proc(image);
end;

procedure zbar_image_set_format(image: zbar_image_t; format: PAnsiChar);
var
  proc: procedure(image: zbar_image_t; format: Cardinal); cdecl;
var
  val: Cardinal;
begin
  GetAddressOf('zbar_image_set_format', @proc);
  val := PCardinal(format)^;
  proc(image, val);
end;

procedure zbar_image_set_sequence(image: zbar_image_t; sequence_num: Cardinal);
var
  proc: procedure(image: zbar_image_t; sequence_num: Cardinal); cdecl;
begin
  GetAddressOf('zbar_image_set_sequence', @proc);
  proc(image, sequence_num);
end;

procedure zbar_image_set_size(image: zbar_image_t; width: Cardinal; height: Cardinal);
var
  proc: procedure(image: zbar_image_t; width: Cardinal; height: Cardinal); cdecl;
begin
  GetAddressOf('zbar_image_set_size', @proc);
  proc(image, width, height);
end;

procedure zbar_image_set_data(image: zbar_image_t; data: Pointer; data_byte_length: Cardinal;
  cleanup_hndlr: zbar_image_cleanup_handler_t);
var
  proc: procedure(image: zbar_image_t; data: Pointer; data_byte_length: Cardinal;
    cleanup_hndlr: zbar_image_cleanup_handler_t); cdecl;
begin
  GetAddressOf('zbar_image_set_data', @proc);
  proc(image, data, data_byte_length, cleanup_hndlr);
end;

procedure zbar_image_free_data(image: zbar_image_t);
var
  proc: procedure(image: zbar_image_t); cdecl;
begin
  GetAddressOf('zbar_image_free_data', @proc);
  proc(image);
end;

procedure zbar_image_set_userdata(image: zbar_image_t; userdata: Pointer);
var
  proc: procedure(image: zbar_image_t; userdata: Pointer); cdecl;
begin
  GetAddressOf('zbar_image_set_userdata', @proc);
  proc(image, userdata);
end;

function zbar_image_get_userdata(image: zbar_image_t): Pointer;
var
  proc: function(image: zbar_image_t): Pointer; cdecl;
begin
  GetAddressOf('zbar_image_get_userdata', @proc);
  Result := proc(image);
end;

function zbar_image_write(image: zbar_image_t; filebase: PAnsiChar): Integer;
var
  proc: function(image: zbar_image_t; filebase: PAnsiChar): Integer; cdecl;
begin
  GetAddressOf('zbar_image_write', @proc);
  Result := proc(image, filebase);
end;

function zbar_image_read(filename: PAnsiChar): zbar_image_t;
var
  proc: function(filename: PAnsiChar): zbar_image_t; cdecl;
begin
  GetAddressOf('zbar_image_read', @proc);
  Result := proc(filename);
end;

function zbar_processor_create(threaded: Integer): zbar_processor_t;
var
  proc: function(threaded: Integer): zbar_processor_t; cdecl;
begin
  GetAddressOf('zbar_processor_create', @proc);
  Result := proc(threaded);
end;

procedure zbar_processor_destroy(processor: zbar_processor_t);
var
  proc: procedure(processor: zbar_processor_t); cdecl;
begin
  GetAddressOf('zbar_processor_destroy', @proc);
  proc(processor);
end;

function zbar_processor_init(processor: zbar_processor_t; video_device: PAnsiChar; enable_display: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; video_device: PAnsiChar; enable_display: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_init', @proc);
  Result := proc(processor, video_device, enable_display);
end;

function zbar_processor_request_size(processor: zbar_processor_t; width: Cardinal; height: Cardinal): Integer;
var
  proc: function(processor: zbar_processor_t; width: Cardinal; height: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_request_size', @proc);
  Result := proc(processor, width, height);
end;

function zbar_processor_request_interface(processor: zbar_processor_t; version: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; version: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_request_interface', @proc);
  Result := proc(processor, version);
end;

function zbar_processor_request_iomode(video: zbar_processor_t; iomode: Integer): Integer;
var
  proc: function(video: zbar_processor_t; iomode: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_request_iomode', @proc);
  Result := proc(video, iomode);
end;

function zbar_processor_force_format(processor: zbar_processor_t; input_format: Cardinal;
  output_format: Cardinal): Integer;
var
  proc: function(processor: zbar_processor_t; input_format: Cardinal; output_format: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_force_format', @proc);
  Result := proc(processor, input_format, output_format);
end;

function zbar_processor_set_data_handler(processor: zbar_processor_t; handler: zbar_image_data_handler_t;
  userdata: PAnsiChar): zbar_image_data_handler_t;
var
  proc: function(processor: zbar_processor_t; handler: zbar_image_data_handler_t; userdata: PAnsiChar)
      : zbar_image_data_handler_t; cdecl;
begin
  GetAddressOf('zbar_processor_set_data_handler', @proc);
  Result := proc(processor, handler, userdata);
end;

procedure zbar_processor_set_userdata(processor: zbar_processor_t; userdata: Pointer);
var
  proc: procedure(processor: zbar_processor_t; userdata: Pointer); cdecl;
begin
  GetAddressOf('zbar_processor_set_userdata', @proc);
  proc(processor, userdata);
end;

function zbar_processor_get_userdata(processor: zbar_processor_t): Pointer;
var
  proc: function(processor: zbar_processor_t): Pointer; cdecl;
begin
  GetAddressOf('zbar_processor_get_userdata', @proc);
  Result := proc(processor);
end;

function zbar_processor_set_config(processor: zbar_processor_t; symbology: zbar_symbol_type_t; config: zbar_config_t;
  value: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; symbology: zbar_symbol_type_t; config: zbar_config_t; value: Integer)
      : Integer; cdecl;
begin
  GetAddressOf('zbar_processor_set_config', @proc);
  Result := proc(processor, symbology, config, value);
end;

function zbar_processor_parse_config(processor: zbar_processor_t; config_string: PAnsiChar): Integer;
var
  sym: zbar_symbol_type_t;
  cfg: zbar_config_t;
  val: Integer;
begin
  Result := zbar_parse_config(config_string, sym, cfg, val) or zbar_processor_set_config(processor, sym, cfg, val);
end;

function zbar_processor_is_visible(processor: zbar_processor_t): Integer;
var
  proc: function(processor: zbar_processor_t): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_is_visible', @proc);
  Result := proc(processor);
end;

function zbar_processor_set_visible(processor: zbar_processor_t; visible: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; visible: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_set_visible', @proc);
  Result := proc(processor, visible);
end;

function zbar_processor_set_active(processor: zbar_processor_t; active: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; active: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_set_active', @proc);
  Result := proc(processor, active);
end;

function zbar_processor_user_wait(processor: zbar_processor_t; timeout: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; timeout: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_processor_user_wait', @proc);
  Result := proc(processor, timeout);
end;

function zbar_process_one(processor: zbar_processor_t; timeout: Integer): Integer;
var
  proc: function(processor: zbar_processor_t; timeout: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_process_one', @proc);
  Result := proc(processor, timeout);
end;

function zbar_process_image(processor: zbar_processor_t; image: zbar_image_t): Integer;
var
  proc: function(processor: zbar_processor_t; image: zbar_image_t): Integer; cdecl;
begin
  GetAddressOf('zbar_process_image', @proc);
  Result := proc(processor, image);
end;

function zbar_processor_error_spew(processor: zbar_processor_t; verbosity: Integer): Integer;
begin
  Result := _zbar_error_spew(processor, verbosity);
end;

function zbar_processor_error_string(processor: zbar_processor_t; verbosity: Integer): PAnsiChar;
begin
  Result := _zbar_error_string(processor, verbosity);
end;

function zbar_processor_get_error_code(processor: zbar_processor_t): zbar_error_t;
begin
  Result := _zbar_get_error_code(processor);
end;

function zbar_video_create: zbar_video_t;
var
  proc: function: zbar_video_t; cdecl;
begin
  GetAddressOf('zbar_video_create', @proc);
  Result := proc;
end;

procedure zbar_video_destroy(video: zbar_video_t);
var
  proc: procedure(video: zbar_video_t); cdecl;
begin
  GetAddressOf('zbar_video_destroy', @proc);
  proc(video);
end;

function zbar_video_open(video: zbar_video_t; device: PAnsiChar): Integer;
var
  proc: function(video: zbar_video_t; device: PAnsiChar): Integer; cdecl;
begin
  GetAddressOf('zbar_video_open', @proc);
  Result := proc(video, device);
end;

function zbar_video_get_fd(video: zbar_video_t): Integer;
var
  proc: function(video: zbar_video_t): Integer; cdecl;
begin
  GetAddressOf('zbar_video_get_fd', @proc);
  Result := proc(video);
end;

function zbar_video_request_size(video: zbar_video_t; width: Cardinal; height: Cardinal): Integer;
var
  proc: function(video: zbar_video_t; width: Cardinal; height: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_video_request_size', @proc);
  Result := proc(video, width, height);
end;

function zbar_video_request_interface(video: zbar_video_t; version: Integer): Integer;
var
  proc: function(video: zbar_video_t; version: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_video_request_interface', @proc);
  Result := proc(video, version);
end;

function zbar_video_request_iomode(video: zbar_video_t; iomode: Integer): Integer;
var
  proc: function(video: zbar_video_t; iomode: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_video_request_iomode', @proc);
  Result := proc(video, iomode);
end;

function zbar_video_get_width(video: zbar_video_t): Integer;
var
  proc: function(video: zbar_video_t): Integer; cdecl;
begin
  GetAddressOf('zbar_video_get_width', @proc);
  Result := proc(video);
end;

function zbar_video_get_height(video: zbar_video_t): Integer;
var
  proc: function(video: zbar_video_t): Integer; cdecl;
begin
  GetAddressOf('zbar_video_get_height', @proc);
  Result := proc(video);
end;

function zbar_video_init(video: zbar_video_t; format: Cardinal): Integer;
var
  proc: function(video: zbar_video_t; format: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_video_init', @proc);
  Result := proc(video, format);
end;

function zbar_video_enable(video: zbar_video_t; enable: Integer): Integer;
var
  proc: function(video: zbar_video_t; enable: Integer): Integer; cdecl;
begin
  GetAddressOf('zbar_video_enable', @proc);
  Result := proc(video, enable);
end;

function zbar_video_next_image(video: zbar_video_t): zbar_image_t;
var
  proc: function(video: zbar_video_t): zbar_image_t; cdecl;
begin
  GetAddressOf('zbar_video_next_image', @proc);
  Result := proc(video);
end;

function zbar_video_error_spew(video: zbar_video_t; verbosity: Integer): Integer;
begin
  Result := _zbar_error_spew(video, verbosity);
end;

function zbar_video_error_string(video: zbar_video_t; verbosity: Integer): PAnsiChar;
begin
  Result := _zbar_error_string(video, verbosity);
end;

function zbar_video_get_error_code(video: zbar_video_t): zbar_error_t;
begin
  Result := _zbar_get_error_code(video);
end;

function zbar_window_create: zbar_window_t;
var
  proc: function: zbar_window_t; cdecl;
begin
  GetAddressOf('zbar_window_create', @proc);
  Result := proc;
end;

procedure zbar_window_destroy(window: zbar_window_t);
var
  proc: procedure(window: zbar_window_t); cdecl;
begin
  GetAddressOf('zbar_window_destroy', @proc);
  proc(window);
end;

function zbar_window_attach(window: zbar_window_t; x11_display_w32_hwnd: Pointer; x11_drawable: Cardinal): Integer;
var
  proc: function(window: zbar_window_t; x11_display_w32_hwnd: Pointer; x11_drawable: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_window_attach', @proc);
  Result := proc(window, x11_display_w32_hwnd, x11_drawable);
end;

procedure zbar_window_set_overlay(window: zbar_window_t; level: Integer);
var
  proc: procedure(window: zbar_window_t; level: Integer); cdecl;
begin
  GetAddressOf('zbar_window_set_overlay', @proc);
  proc(window, level);
end;

function zbar_window_draw(window: zbar_window_t; image: zbar_image_t): Integer;
var
  proc: function(window: zbar_window_t; image: zbar_image_t): Integer; cdecl;
begin
  GetAddressOf('zbar_window_draw', @proc);
  Result := proc(window, image);
end;

function zbar_window_redraw(window: zbar_window_t): Integer;
var
  proc: function(window: zbar_window_t): Integer; cdecl;
begin
  GetAddressOf('zbar_window_redraw', @proc);
  Result := proc(window);
end;

function zbar_window_resize(window: zbar_window_t; width: Cardinal; height: Cardinal): Integer;
var
  proc: function(window: zbar_window_t; width: Cardinal; height: Cardinal): Integer; cdecl;
begin
  GetAddressOf('zbar_window_resize', @proc);
  Result := proc(window, width, height);
end;

function zbar_window_error_spew(window: zbar_window_t; verbosity: Integer): Integer;
begin
  Result := _zbar_error_spew(window, verbosity);
end;

function zbar_window_error_string(window: zbar_window_t; verbosity: Integer): PAnsiChar;
begin
  Result := _zbar_error_string(window, verbosity);
end;

function zbar_window_get_error_code(window: zbar_window_t): zbar_error_t;
begin
  Result := _zbar_get_error_code(window);
end;

function zbar_negotiate_format(video: zbar_video_t; window: zbar_window_t): Integer;
var
  proc: function(video: zbar_video_t; window: zbar_window_t): Integer; cdecl;
begin
  GetAddressOf('zbar_negotiate_format', @proc);
  Result := proc(video, window);
end;

function zbar_image_scanner_create: zbar_image_scanner_t;
var
  proc: function: zbar_image_scanner_t; cdecl;
begin
  GetAddressOf('zbar_image_scanner_create', @proc);
  Result := proc;
end;

procedure zbar_image_scanner_destroy(scanner: zbar_image_scanner_t);
var
  proc: procedure(scanner: zbar_image_scanner_t); cdecl;
begin
  GetAddressOf('zbar_image_scanner_destroy', @proc);
  proc(scanner);
end;

function zbar_image_scanner_set_data_handler(scanner: zbar_image_scanner_t; handler: zbar_image_data_handler_t;
  userdata: Pointer): zbar_image_data_handler_t;
var
  proc: function(scanner: zbar_image_scanner_t; handler: zbar_image_data_handler_t; userdata: Pointer)
      : zbar_image_data_handler_t; cdecl;
begin
  GetAddressOf('zbar_image_scanner_set_data_handler', @proc);
  Result := proc(scanner, handler, userdata);
end;

function zbar_image_scanner_set_config(scanner: zbar_image_scanner_t; symbology: zbar_symbol_type_t;
  config: zbar_config_t; value: Integer): Integer;
var
  proc: function(scanner: zbar_image_scanner_t; symbology: zbar_symbol_type_t; config: zbar_config_t; value: Integer)
      : Integer; cdecl;
begin
  GetAddressOf('zbar_image_scanner_set_config', @proc);
  Result := proc(scanner, symbology, config, value);
end;

function zbar_image_scanner_parse_config(scanner: zbar_image_scanner_t; config_string: PAnsiChar): Integer;
var
  sym: zbar_symbol_type_t;
  cfg: zbar_config_t;
  val: Integer;
begin
  Result := zbar_parse_config(config_string, &sym, &cfg, &val) or zbar_image_scanner_set_config(scanner, sym, cfg, val);
end;

procedure zbar_image_scanner_enable_cache(scanner: zbar_image_scanner_t; enable: Integer);
var
  proc: procedure(scanner: zbar_image_scanner_t; enable: Integer); cdecl;
begin
  GetAddressOf('zbar_image_scanner_enable_cache', @proc);
  proc(scanner, enable);
end;

function zbar_scan_image(scanner: zbar_image_scanner_t; image: zbar_image_t): Integer;
var
  proc: function(scanner: zbar_image_scanner_t; image: zbar_image_t): Integer; cdecl;
begin
  GetAddressOf('zbar_scan_image', @proc);
  Result := proc(scanner, image);
end;

function zbar_decoder_create: zbar_decoder_t;
var
  proc: function: zbar_decoder_t; cdecl;
begin
  GetAddressOf('zbar_decoder_create', @proc);
  Result := proc;
end;

procedure zbar_decoder_destroy(decoder: zbar_decoder_t);
var
  proc: procedure(decoder: zbar_decoder_t); cdecl;
begin
  GetAddressOf('zbar_decoder_destroy', @proc);
  proc(decoder);
end;

function zbar_decoder_set_config(decoder: zbar_decoder_t; symbology: zbar_symbol_type_t; config: zbar_config_t;
  value: Integer): Integer;
var
  proc: function(decoder: zbar_decoder_t; symbology: zbar_symbol_type_t; config: zbar_config_t; value: Integer)
      : Integer; cdecl;
begin
  GetAddressOf('zbar_decoder_set_config', @proc);
  Result := proc(decoder, symbology, config, value);
end;

function zbar_decoder_parse_config(decoder: zbar_decoder_t; config_string: PAnsiChar): Integer;
var
  sym: zbar_symbol_type_t;
  cfg: zbar_config_t;
  val: Integer;
begin
  Result := zbar_parse_config(config_string, &sym, &cfg, &val) or zbar_decoder_set_config(decoder, sym, cfg, val);
end;

procedure zbar_decoder_reset(decoder: zbar_decoder_t);
var
  proc: procedure(decoder: zbar_decoder_t); cdecl;
begin
  GetAddressOf('zbar_decoder_reset', @proc);
  proc(decoder);
end;

procedure zbar_decoder_new_scan(decoder: zbar_decoder_t);
var
  proc: procedure(decoder: zbar_decoder_t); cdecl;
begin
  GetAddressOf('zbar_decoder_new_scan', @proc);
  proc(decoder);
end;

function zbar_decode_width(decoder: zbar_decoder_t; width: Cardinal): zbar_symbol_type_t;
var
  proc: function(decoder: zbar_decoder_t; width: Cardinal): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_decode_width', @proc);
  Result := proc(decoder, width);
end;

function zbar_decoder_get_color(decoder: zbar_decoder_t): zbar_color_t;
var
  proc: function(decoder: zbar_decoder_t): zbar_color_t; cdecl;
begin
  GetAddressOf('zbar_decoder_get_color', @proc);
  Result := proc(decoder);
end;

function zbar_decoder_get_data(decoder: zbar_decoder_t): PAnsiChar;
var
  proc: function(decoder: zbar_decoder_t): PAnsiChar; cdecl;
begin
  GetAddressOf('zbar_decoder_get_data', @proc);
  Result := proc(decoder);
end;

function zbar_decoder_get_type(decoder: zbar_decoder_t): zbar_symbol_type_t;
var
  proc: function(decoder: zbar_decoder_t): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_decoder_get_type', @proc);
  Result := proc(decoder);
end;

function zbar_decoder_set_handler(decoder: zbar_decoder_t; handler: zbar_decoder_handler_t): zbar_decoder_handler_t;
var
  proc: function(decoder: zbar_decoder_t; handler: zbar_decoder_handler_t): zbar_decoder_handler_t; cdecl;
begin
  GetAddressOf('zbar_decoder_set_handler', @proc);
  Result := proc(decoder, handler);
end;

procedure zbar_decoder_set_userdata(decoder: zbar_decoder_t; userdata: Pointer);
var
  proc: procedure(decoder: zbar_decoder_t; userdata: Pointer); cdecl;
begin
  GetAddressOf('zbar_decoder_set_userdata', @proc);
  proc(decoder, userdata);
end;

function zbar_decoder_get_userdata(decoder: zbar_decoder_t): Pointer;
var
  proc: function(decoder: zbar_decoder_t): Pointer; cdecl;
begin
  GetAddressOf('zbar_decoder_get_userdata', @proc);
  Result := proc(decoder);
end;

function zbar_scanner_create(decoder: zbar_decoder_t): zbar_scanner_t;
var
  proc: function(decoder: zbar_decoder_t): zbar_scanner_t; cdecl;
begin
  GetAddressOf('zbar_scanner_create', @proc);
  Result := proc(decoder);
end;

procedure zbar_scanner_destroy(scanner: zbar_scanner_t);
var
  proc: procedure(scanner: zbar_scanner_t); cdecl;
begin
  GetAddressOf('zbar_scanner_destroy', @proc);
  proc(scanner);
end;

function zbar_scanner_reset(scanner: zbar_scanner_t): zbar_symbol_type_t;
var
  proc: function(scanner: zbar_scanner_t): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_scanner_reset', @proc);
  Result := proc(scanner);
end;

function zbar_scanner_new_scan(scanner: zbar_scanner_t): zbar_symbol_type_t;
var
  proc: function(scanner: zbar_scanner_t): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_scanner_new_scan', @proc);
  Result := proc(scanner);
end;

function zbar_scan_y(scanner: zbar_scanner_t; y: Integer): zbar_symbol_type_t;
var
  proc: function(scanner: zbar_scanner_t; y: Integer): zbar_symbol_type_t; cdecl;
begin
  GetAddressOf('zbar_scan_y', @proc);
  Result := proc(scanner, y);
end;

function zbar_scan_rgb24(scanner: zbar_scanner_t; rgb: PAnsiChar): zbar_symbol_type_t;
begin
  Result := zbar_scan_y(scanner, Ord(rgb^) + Ord((rgb + 1)^) + Ord((rgb + 2)^));
end;

function zbar_scanner_get_width(scanner: zbar_scanner_t): Cardinal;
var
  proc: function(scanner: zbar_scanner_t): Cardinal; cdecl;
begin
  GetAddressOf('zbar_scanner_get_width', @proc);
  Result := proc(scanner);
end;

function zbar_scanner_get_color(scanner: zbar_scanner_t): zbar_color_t;
var
  proc: function(scanner: zbar_scanner_t): zbar_color_t; cdecl;
begin
  GetAddressOf('zbar_scanner_get_color', @proc);
  Result := proc(scanner);
end;



initialization

  DllHandle := LoadLibrary('libzbar-0.dll');
//  if DllHandle = 0 then
    //RaiseLastOSError;

finalization

  if (DllHandle <> 0) then
    FreeLibrary(DllHandle);

end.
