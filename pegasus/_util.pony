
use "format"

primitive _Util
  fun string_escape(s: String): String =>
    let output = recover String end
    let iter = s.values()
    try
      while iter.has_next() do
        let byte = iter.next()
        if byte == '"' then
          output.append("\\\"")
        elseif byte < 0x10 then
          output.append("\\x0" + Format.int[U8](byte, FormatHexBare))
        elseif byte < 0x20 then
          output.append("\\x" + Format.int[U8](byte, FormatHexBare))
        elseif byte < 0x7F then
          output.push(byte)
        else
          output.append("\\x" + Format.int[U8](byte, FormatHexBare))
        end
      end
    end
    output
