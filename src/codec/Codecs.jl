module Codecs

@enum(WireType, VARINT=0, FIXED64=1, LENGTH_DELIMITED=2, START_GROUP=3, END_GROUP=4, FIXED32=5)

struct ProtoDecoder{I<:IO,F<:Function}
    io::I
    message_done::F
end
message_done(d::ProtoDecoder) = d.message_done(d.io)
ProtoDecoder(io::IO) = ProtoDecoder(io, eof)
function try_eat_end_group(d::ProtoDecoder, wire_type::WireType)
    wire_type == START_GROUP && read(d, UInt8) # read end group
    return nothing
end
struct ProtoEncoder{I<:IO}
    io::I
end

zigzag_encode(x::T) where {T <: Integer} = xor(x << 1, x >> (8 * sizeof(T) - 1))
zigzag_decode(x::T) where {T <: Integer} = xor(x >> 1, -(x & T(1)))
_max_varint_size(::Type{T}) where {T} = (sizeof(T) + div(sizeof(T), 4))
_varint_size(x) = cld((8sizeof(x) - leading_zeros(x)), 7)

include("decode.jl")
include("encode.jl")

end # module