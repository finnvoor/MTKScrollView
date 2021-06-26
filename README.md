# `MTKScrollView`

A view that allows the scrolling and zooming of a MTKView, providing a `simd_float4x4` view matrix for use in vertex shaders.  The view handles redrawing by calling `setNeedsDisplay()` when the view matrix has been updated.