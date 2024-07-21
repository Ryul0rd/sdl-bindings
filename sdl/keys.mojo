from sys import ffi


var path = '/lib/x86_64-linux-gnu/libSDL2-2.0.so'
var sdl = ffi.DLHandle(path)


var _get_keyboard_state = sdl.get_function[fn(UnsafePointer[Int32]) -> UnsafePointer[UInt8]]('SDL_GetKeyboardState')
fn get_keyboard_state() -> List[Bool]:
    var len_ptr = UnsafePointer(Int32())
    var keys_ptr = _get_keyboard_state(len_ptr)
    var keys_list = List[Bool](capacity=int(len_ptr[]))
    for i in range(len_ptr[]):
        keys_list.append(keys_ptr[i])
    return keys_list


alias retvrn = ord('\r')
alias escape = ord('\x1B')
alias backspace = ord('\b')
alias tab = ord('\t')
alias space = ord(' ')
alias exclaim = ord('!')
alias quotedbl = ord('"')
alias hash = ord('#')
alias percent = ord('%')
alias dollar = ord('$')
alias ampersand = ord('&')
alias quote = ord("'")
alias leftparen = ord('(')
alias rightparen = ord(')')
alias asterisk = ord('*')
alias plus = ord('+')
alias comma = ord(',')
alias minus = ord('-')
alias period = ord('.')
alias slash = ord('/')
alias n0 = ord('0')
alias n1 = ord('1')
alias n2 = ord('2')
alias n3 = ord('3')
alias n4 = ord('4')
alias n5 = ord('5')
alias n6 = ord('6')
alias n7 = ord('7')
alias n8 = ord('8')
alias n9 = ord('9')
alias colon = ord(':')
alias semicolon = ord(';')
alias less = ord('<')
alias equals = ord('=')
alias greater = ord('>')
alias question = ord('?')
alias at = ord('@')
# skip uppercase letters
alias leftbracket = ord('[')
alias backslash = ord('\\')
alias rightbracket = ord(']')
alias caret = ord('^')
alias underscore = ord('_')
alias backquote = ord('`')
alias a = ord('a')
alias b = ord('b')
alias c = ord('c')
alias d = ord('d')
alias e = ord('e')
alias f = ord('f')
alias g = ord('g')
alias h = ord('h')
alias i = ord('i')
alias j = ord('j')
alias k = ord('k')
alias l = ord('l')
alias m = ord('m')
alias n = ord('n')
alias o = ord('o')
alias p = ord('p')
alias q = ord('q')
alias r = ord('r')
alias s = ord('s')
alias t = ord('t')
alias u = ord('u')
alias v = ord('v')
alias w = ord('w')
alias x = ord('x')
alias y = ord('y')
alias z = ord('z')