#==============================================================================
# ** Auto Font Install
#------------------------------------------------------------------------------
# Wachunga
# Version 1.1
# 2006-05-26
# See https://github.com/Wachunga/rmxp-auto-font-install for details
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# * SDK Log Script
#------------------------------------------------------------------------------
SDK.log('Auto Font Install', 'Wachunga', 1.1, '2006-05-26')

#------------------------------------------------------------------------------
# * Begin SDK Enabled Check
#------------------------------------------------------------------------------
if SDK.state('Auto Font Install') == true

  module Fonts
    # filenames of fonts to be in stalled
    Filenames = ['FUTRFW.TTF']
    
    # names (not filenames) of fonts to be installed
    Names = ['Futurist Fixed-width']
  
    # whether to notify player (via pop-up message) that fonts were installed
    Notify = true
    
    # location of fonts (relative to game folder)
    Source = 'Fonts/'
    
    # location of fonts after installation
    Dest = ENV['SystemRoot'] + '\Fonts\\'
  end
  
  class Scene_Title
    
    AFR = Win32API.new('gdi32', 'AddFontResource', ['P'], 'L')
    WPS = Win32API.new('kernel32', 'WriteProfileString', ['P'] * 3, 'L')
    SM = Win32API.new('user32', 'SendMessage', ['L'] * 4, 'L')
    WM_FONTCHANGE = 0x001D
    HWND_BROADCAST = 0xffff
  
    alias wachunga_autofontinstall_st_main main
    def main
      success = []
      for i in 0...Fonts::Filenames.size
        f = Fonts::Filenames[i]
        # check if already installed...
        if not FileTest.exists?(Fonts::Dest + f)
          # check to ensure font is in specified location...
          if FileTest.exists?(Fonts::Source + f)
            require Dir.getwd + '/Data/fileutils.rb'
            # copy file to fonts folder
            FileUtils.cp(Fonts::Source + f, Fonts::Dest + f)
            # add font resource
            AFR.call(Fonts::Dest + f)
            # add entry to win.ini/registry
            WPS.call('Fonts', Fonts::Names[i] + ' (TrueType)', f)
            SM.call(HWND_BROADCAST,WM_FONTCHANGE,0,0)
            if FileTest.exists?(Fonts::Dest + f)
              success.push(Fonts::Names[i])
            else
              print "Auto Font Install:\n\nFailed to install " +
                Fonts::Names[i] + '.'
            end
          else
            print "Auto Font Install:\n\nFont " + f + " not found."
          end
        end
      end
      if success != [] # one or more fonts successfully installed
        if Fonts::Notify
          fonts = ''
          success.each do |f|
            fonts << f << ', '
          end
          print "Auto Font Install:\n\nSucessfully installed " + fonts[0..-3] +
            '.'
        end
        # new fonts aren't recognized in RMXP until the program is
        # restarted, so this is (unfortunately) necessary
        a = Thread.new { system('Game') }
        exit
      end
      wachunga_autofontinstall_st_main
    end

  end

#------------------------------------------------------------------------------
# * End SDK Enable Test
#------------------------------------------------------------------------------
end
