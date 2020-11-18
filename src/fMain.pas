{*------------------------------------------------------------------------
 *  Copyright 2007-2010 (c) Jeff Brown <spadix@users.sourceforge.net>
 *
 *  This file is part of the ZBar Bar Code Reader.
 *
 *  The ZBar Bar Code Reader is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser Public License as
 *  published by the Free Software Foundation; either version 2.1 of
 *  the License, or (at your option) any later version.
 *
 *  The ZBar Bar Code Reader is distributed in the hope that it will be
 *  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 *  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser Public License
 *  along with the ZBar Bar Code Reader; if not, write to the Free
 *  Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 *  Boston, MA  02110-1301  USA
 *
 *  http://sourceforge.net/projects/zbar
 *
 * Conversion to Delphi Copyright 2013 (c) Aleksandr Nazaruk <support@freehand.com.ua>
 * Conversion to Delphi2007 Copyright 2017 (c) Hao Lin Chang <kuei@kiss99.com>
 *------------------------------------------------------------------------*}

unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ZBar, magick_wand, ImageMagick, ExtCtrls, StdCtrls;

const
  note_usage =
    'usage: zbarimg [options] <image>...' + #10#13 +
    #10#13 +
    'scan and decode bar codes from one or more image files' + #10#13 +
    #10#13 +
    'options:' + #10#13 +
    '    -h, --help      display this help text' + #10#13 +
    '    --version       display version information and exit' + #10#13 +
    '    -q, --quiet     minimal output, only print decoded symbol data' + #10#13 +
    '    -v, --verbose   increase debug output level' + #10#13 +
    '    --verbose=N     set specific debug output level' + #10#13 +
    '    -d, --display   enable display of following images to the screen' + #10#13 +
    '    -D, --nodisplay disable display of following images (default)' + #10#13 +
    '    --xml, --noxml  enable/disable XML output format' + #10#13 +
    '    --raw           output decoded symbol data without symbology prefix' + #10#13 +
    '    -S<CONFIG>[=<VALUE>], --set <CONFIG>[=<VALUE>]' + #10#13 +
    '                    set decoder/scanner <CONFIG> to <VALUE> (or 1)' + #10#13;

const
  warning_not_found =
    #10#13 +
    'WARNING: barcode data was not detected in some image(s)' + #10#13 +
    '  things to check:' + #10#13 +
    '    - is the barcode type supported?' +
    '  currently supported symbologies are:' + #10#13 +
    '      EAN/UPC (EAN-13, EAN-8, EAN-2, EAN-5, UPC-A, UPC-E,' + #10#13 +
    '      ISBN-10, ISBN-13), Code 128, Code 93, Code 39, DataBar,' + #10#13 +
    '      DataBar Expanded, and Interleaved 2 of 5' + #10#13 +
    '    - is the barcode large enough in the image?' + #10#13 +
    '    - is the barcode mostly in focus?' + #10#13 +
    '    - is there sufficient contrast/illumination?' + #10#13;

const
  xml_head =
    '<barcodes xmlns="http://zbar.sourceforge.net/2008/barcode">';

const
  xml_foot =
    '</barcodes>';
type
  TFormZBar = class(TForm)
    tmrBegin: TTimer;
    moLog: TMemo;
    Panel1: TPanel;
    cbComm: TComboBox;
    Label1: TLabel;
    btnAdd: TButton;
    boxComm: TListBox;
    btnRun: TButton;
    Button2: TButton;
    tmrRun: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrBeginTimer(Sender: TObject);
    procedure tmrRunTimer(Sender: TObject);
  private
    display: integer;
    exit_code: integer;
    init: Boolean;
    lstParam: TStrings;
    major: cardinal;
    minor: cardinal;
    notfound: integer;
    num_images: integer;
    num_symbols: integer;
    processor: zbar_processor_t;
    quiet: integer;
    RunID: Integer;
    xmlbuf: PAnsichar;
    xmlbuflen: Cardinal;
    xmllvl: integer;
    function dump_error(wand: PMagickWand): integer;
    function parse_config(cfgstr: PAnsiChar; arg: PAnsiChar): integer;
    function scan_image(filename: PAnsiChar): integer;
    function usage(rc: integer; msg: PAnsiChar; arg: PAnsiChar): integer;
  end;

var
  FormZBar: TFormZBar;

implementation

{$R *.dfm}

procedure TFormZBar.btnAddClick(Sender: TObject);
begin
  if cbComm.Text <> '' then
    boxComm.Items.Add(cbComm.Text);
end;

procedure TFormZBar.btnRunClick(Sender: TObject);
begin
  if boxComm.Items.Count <= 0 then
    Exit;

  RunID := 0;
  tmrRun.Enabled := True;
end;

procedure TFormZBar.Button2Click(Sender: TObject);
begin
  boxComm.Items.Clear;
end;

function TFormZBar.dump_error(wand: PMagickWand): integer;
const
  sevdesc: array[0..2] of AnsiString = ('WARNING', 'ERROR', 'FATAL');
var
  desc: PAnsiChar;
  severity: ExceptionType;
begin
  desc := MagickGetException(wand, @severity);
  if (severity >= FatalErrorException) then
    exit_code := 2
  else if (severity >= ErrorException) then
    exit_code := 1
  else
    exit_code := 0;
  moLog.Lines.Add(format('%s: %s', [sevdesc[exit_code], desc]));
  MagickRelinquishMemory(desc);
  result := exit_code;
end;

procedure TFormZBar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if processor <> nil then
      zbar_processor_destroy(processor);
    //DestroyMagick();
  except
  end;

  lstParam.Clear;
  lstParam.Destroy;
end;

procedure TFormZBar.FormCreate(Sender: TObject);
var
  i, j: integer;
  arg: array[0..255] of AnsiChar;

  sArg: string;
begin
  notfound := 0;
  exit_code := 0;
  num_images := 0;
  num_symbols := 0;
  xmllvl := 0;
  xmlbuf := nil;
  xmlbuflen := 0;
  processor := nil;
  quiet := 0;
  display := 0;

  moLog.Lines.Clear;

  lstParam := TStringList.Create;

  { TODO -oUser -cConsole Main : Insert code here }
  for i := 1 to ParamCount do
  begin
    fillchar(arg, sizeof(arg), #0);
    StrPCopy(arg, ParamStr(i));

    sArg := arg;
    lstParam.Add(sArg);

    if ((arg[0] <> '-') or (arg[1] = '')) then
    begin
      inc(num_images);
    end
    else if arg[1] <> '-' then
    begin
      for j := 1 to length(arg) - 1 do
      begin
        if arg[j] = 'S' then
        begin
          ;
        end;
        if arg[j] = 'h' then
        begin
          usage(0, '', '');
          exit;
        end
        else if arg[j] = 'q' then
        begin
          quiet := 1;
          break;
        end
        else if arg[j] = 'v' then
        begin
          zbar_increase_verbosity();
          break
        end
        else if arg[j] = 'd' then
        begin
          display := 1;
          break
        end
        else if arg[j] = 'D' then
          break
        else
        begin
          usage(1, 'ERROR: unknown bundled option: -', arg);
          //exit;
        end;
      end;
    end
    else if AnsiCompareStr(arg, '--help') = 0 then
    begin
      usage(0, '', '');
      exit;
    end
    else if AnsiCompareStr(arg, '--version') = 0 then
    begin
      zbar_version(major, minor);
      moLog.Lines.Add(format('%d.%d', [major, minor]));
      exit;
    end
    else if AnsiCompareStr(arg, '--quiet') = 0 then
    begin
      quiet := 1;
      // exit; //-----------?
    end
    else if AnsiCompareStr(arg, '--verbose') = 0 then
    begin
      zbar_increase_verbosity();
    end
    else if AnsiCompareStr(copy(arg, 1, 10), '--verbose=') = 0 then
    begin
      try
        zbar_set_verbosity(strtoint(copy(arg, 11, length(arg) - 10)));
      except
        zbar_set_verbosity(0);
      end;
    end
    else if AnsiCompareStr(arg, '--display') = 0 then
    begin
      inc(display);
    end
    else if ((AnsiCompareStr(arg, '--nodisplay') = 0) or
      (AnsiCompareStr(arg, '--set') = 0) or
      (AnsiCompareStr(arg, '--xml') = 0) or
      (AnsiCompareStr(arg, '--noxml') = 0) or
      (AnsiCompareStr(arg, '--raw') = 0)) then
    begin
      continue;
    end
    else
      usage(1, 'ERROR: unknown option: ', arg);
  end;

  init := False;
end;

procedure TFormZBar.FormShow(Sender: TObject);
begin
  if not init then
  begin
    init := True;

    {if num_images = 0 then
    begin
      usage(1, 'ERROR: specify image file(s) to scan', '');
      Application.Terminate;
      //exit;
    end;}
    num_images := 0;

    tmrBegin.Enabled := True;
  end;
end;

function TFormZBar.parse_config(cfgstr: PAnsiChar; arg: PAnsiChar): integer;
begin
  result := 0;
  if length(cfgstr) > 0 then
    result := usage(1, 'ERROR: need argument for option: ', arg);

  if zbar_processor_parse_config(processor, cfgstr) = 0 then
    result := usage(1, 'ERROR: invalid configuration setting:', cfgstr);
end;

function TFormZBar.scan_image(filename: PAnsiChar): integer;
type
  cuint32 = LongWord;
type
  size_t = cuint32;

var
  found: integer;
  images: PMagickWand;
  seq, n: cardinal;
  zimage: zbar_image_t;
  width: integer;
  height: integer;
  bloblen: size_t;
  blob: PByte;
  sym: zbar_symbol_t;
  typ: zbar_symbol_type_t;
  len: integer;
begin
  found := 0;

  if (exit_code = 3) then
    result := -1;

  images := NewMagickWand();
  if ((MagickReadImage(images, filename) = MagickFalse) and (dump_error(images) > 0)) then
    result := -1;

  {if(!MagickReadImage(images, filename) && dump_error(images))
      return(-1); }

  n := MagickGetNumberImages(images);
  for seq := 0 to n - 1 do
  begin
    if (exit_code = 3) then
      result := -1;

    if ((MagickSetImageIndex(images, seq) = MagickFalse) and (dump_error(images) > 0)) then
      result := -1;

    zimage := zbar_image_create;
    Assert(Assigned(zimage), 'zbar-image');
    zbar_image_set_format(zimage, 'Y800');

    width := MagickGetImageWidth(images);
    height := MagickGetImageHeight(images);
    zbar_image_set_size(zimage, width, height);
    zbar_image_set_size(zimage, Width, Height);

    // extract grayscale image pixels
    // FIXME color!! ...preserve most color w/422P
    // (but only if it's a color image)
    bloblen := width * height;
    blob := GetMemory(bloblen);
    zbar_image_set_data(zimage, blob, bloblen, nil);

    if MagickGetImagePixels(images, 0, 0, width, height, 'I', CharPixel, blob) = MagickFalse then
      result := -1;

    if (xmllvl = 1) then
    begin
      inc(xmllvl);
      moLog.Lines.Add(Format('<source href="%s">', [filename]));
    end;

    zbar_process_image(processor, zimage);

    // output result data
    sym := zbar_image_first_symbol(zimage);
    while Assigned(sym) do
    begin
      typ := zbar_symbol_get_type(sym);
      //len := zbar_symbol_get_data_length(sym);
      if typ = ZBAR_PARTIAL then
        continue;

      if (xmllvl <= 0) then
      begin
        if xmllvl = 0 then
          moLog.Lines.Add(Format('%s:', [zbar_get_symbol_name(typ)]));
        moLog.Lines.Add(string(AnsiString(zbar_symbol_get_data(sym))))
      end
      else
      begin
        if (xmllvl < 3) then
        begin
          inc(xmllvl);
          moLog.Lines.Add(Format('<index num="%u">', [seq]));
        end;
        zbar_symbol_xml(sym, xmlbuf, xmlbuflen);
        moLog.Lines.Add(xmlbuf);
      end;
      inc(found);
      inc(num_symbols);
      sym := zbar_symbol_next(sym);
    end;

    if (xmllvl > 2) then
    begin
      dec(xmllvl);
      moLog.Lines.Add('</index>');
    end;

    //moLog.Lines.Addtofile;
    zbar_image_destroy(zimage);
    inc(num_images);
    if zbar_processor_is_visible(processor) = 1 then
      zbar_processor_user_wait(processor, -1);
  end;

  if (xmllvl > 1) then
  begin
    dec(xmllvl);
    moLog.Lines.Add('</source>');
  end;

  if found = 0 then
    inc(notfound);
  DestroyMagickWand(images);
  result := 0;
end;

procedure TFormZBar.tmrBeginTimer(Sender: TObject);
var
  i, j: Integer;
  ParamTotal: Integer;
  arg: string;
begin
  tmrBegin.Enabled := False;

  cbComm.Text := 'Test01.png';
  boxComm.Items.Clear;
  boxComm.Items.Add('Test01.png');


  processor := zbar_processor_create(0);
  Assert(Assigned(processor), 'zbar-processor');
  if zbar_processor_init(processor, nil, 1) = 1 then
  begin
    zbar_processor_error_spew(processor, 0);
  end;

  ParamTotal := lstParam.Count;
  for i := 0 to ParamTotal - 1 do
  begin
    arg := moLog.Lines.Strings[i];
    if length(arg) <= 0 then
      continue;
    if ((arg[1] <> '-') or (arg[2] = '')) then
    begin
      scan_image(PAnsiChar(arg));
    end
    else if arg[2] <> '-' then
    begin
      for j := 1 to length(arg) do
      begin
        if arg[j] = 'S' then
        begin
          ;
        end
        else if arg[j] = 'd' then
        begin
          zbar_processor_set_visible(processor, 1);
          break
        end
        else if arg[j] = 'D' then
        begin
          zbar_processor_set_visible(processor, 0);
          break;
        end
      end;
    end
    else if AnsiCompareStr(arg, '--display') = 0 then
    begin
      zbar_processor_set_visible(processor, 1);
    end
    else if AnsiCompareStr(arg, '--nodisplay') = 0 then
    begin
      zbar_processor_set_visible(processor, 0);
    end
    else if AnsiCompareStr(arg, '--xml') = 0 then
    begin
      if (xmllvl < 1) then
      begin
        xmllvl := 1;
        //fflush(stdout);
        //_setmode(_fileno(stdout), _O_BINARY);
        moLog.Lines.Add(Format('%s', [xml_head]));
      end;
    end
    else if ((AnsiCompareStr(arg, '--noxml') = 0) or (AnsiCompareStr(arg, '--raw') = 0)) then
    begin
      if (xmllvl > 0) then
      begin
        xmllvl := 0;
        //fflush(stdout);
        //_setmode(_fileno(stdout), _O_BINARY);
        moLog.Lines.Add(Format('%s', [xml_head]));
      end;
      if AnsiCompareStr(arg, '--raw') = 0 then
      begin
        xmllvl := -1;
      end;
    end
    else if AnsiCompareStr(arg, '--') = 0 then
      break;
  end;

  for i := 0 to ParamTotal - 1 do
  begin
    scan_image(PansiChar(ParamStr(i)));
  end;

  //* ignore quit during last image *//
  if (exit_code = 3) then
    exit_code := 0;

  if (xmllvl > 0) then
  begin
    xmllvl := -1;
    moLog.Lines.Add(Format('%s', [xml_foot]));
    //fflush(stdout);
  end;

  //  if Assigned(xmlbuf) then
  //      freeMem(xmlbuf);

  if ((num_images > 0) and (quiet = 0) and (xmllvl <= 0)) then
  begin
    moLog.Lines.Add(Format('scanned %d barcode symbols from %d images', [num_symbols, num_images]));
    if (notfound > 0) then
      moLog.Lines.Add(Format('%s', [warning_not_found]));
  end;

  if ((num_images > 0) and (notfound > 0) and (exit_code <> 0)) then
    exit_code := 4;
end;

procedure TFormZBar.tmrRunTimer(Sender: TObject);
var
  arg: string;
  j: Integer;
begin
  if RunID >= boxComm.Items.Count then
  begin
    tmrRun.Enabled := False;
    Exit;
  end;
  arg := boxComm.Items.Strings[RunID];
  inc(RunID);

  if length(arg) <= 0 then
    Exit;

  tmrRun.Enabled := False;
  try
    if ((arg[1] <> '-') or (arg[2] = '')) then
    begin
      scan_image(PAnsiChar(arg));
    end
    else if arg[2] <> '-' then
    begin
      for j := 1 to length(arg) do
      begin
        if arg[j] = 'S' then
        begin
          ;
        end
        else if arg[j] = 'd' then
        begin
          zbar_processor_set_visible(processor, 1);
          Break;
        end
        else if arg[j] = 'D' then
        begin
          zbar_processor_set_visible(processor, 0);
          Break;
        end
      end;
    end
    else if AnsiCompareStr(arg, '--display') = 0 then
    begin
      zbar_processor_set_visible(processor, 1);
    end
    else if AnsiCompareStr(arg, '--nodisplay') = 0 then
    begin
      zbar_processor_set_visible(processor, 0);
    end
    else if AnsiCompareStr(arg, '--xml') = 0 then
    begin
      if (xmllvl < 1) then
      begin
        xmllvl := 1;
        //fflush(stdout);
        //_setmode(_fileno(stdout), _O_BINARY);
        moLog.Lines.Add(Format('%s', [xml_head]));
      end;
    end
    else if ((AnsiCompareStr(arg, '--noxml') = 0) or (AnsiCompareStr(arg, '--raw') = 0)) then
    begin
      if (xmllvl > 0) then
      begin
        xmllvl := 0;
        //fflush(stdout);
        //_setmode(_fileno(stdout), _O_BINARY);
        moLog.Lines.Add(Format('%s', [xml_head]));
      end;
      if AnsiCompareStr(arg, '--raw') = 0 then
      begin
        xmllvl := -1;
      end;
    end;

    //* ignore quit during last image *//
    if (exit_code = 3) then
      exit_code := 0;

    if (xmllvl > 0) then
    begin
      xmllvl := -1;
      moLog.Lines.Add(Format('%s', [xml_foot]));
      //fflush(stdout);
    end;

    //  if Assigned(xmlbuf) then
    //      freeMem(xmlbuf);

    if ((num_images > 0) and (quiet = 0) and (xmllvl <= 0)) then
    begin
      moLog.Lines.Add(Format('scanned %d barcode symbols from %d images', [num_symbols, num_images]));
      if (notfound > 0) then
        moLog.Lines.Add(Format('%s', [warning_not_found]));
    end;

    if ((num_images > 0) and (notfound > 0) and (exit_code <> 0)) then
      exit_code := 4;
  finally
    tmrRun.Enabled := True;
  end;
end;

function TFormZBar.usage(rc: integer; msg: PAnsiChar; arg: PAnsiChar): integer;
begin
  if length(msg) > 0 then
  begin
    moLog.Lines.Add(format('%s', [msg]));
    if length(arg) > 0 then
      moLog.Lines.Add(format('%s', [arg]));
    moLog.Lines.Add('');
  end;
  moLog.Lines.Add(format('%s', [note_usage]));
  result := rc;
end;

end.
