
#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_noise;
uniform float u_interpolate;

void main() {
    
//    vec2 displacedTexCoord = v_texCoord + vec2(texture2D(u_noise, v_texCoord +  vec2(sin(u_interpolate) * 0.1 ,0)).x,texture2D(u_noise, v_texCoord + vec2(0,cos(u_interpolate) * 0.1)).y) * 0.25;
    
    
    vec2 displacedTexCoord = v_texCoord + vec2(texture2D(u_noise,v_texCoord  + vec2(sin(u_interpolate) * 0.1,0)).z - 0.5,
                                               texture2D(u_noise,v_texCoord + vec2(0,cos(u_interpolate) * 0.1 )).z - 0.5) * 0.04;
    
//    vec4 color1 = texture2D(CC_Texture0, v_texCoord);
    vec4 color2 = texture2D(CC_Texture0, displacedTexCoord);
    
    
    gl_FragColor = color2;
    //    gl_FragColor = v_fragmentColor * mix( color1, color2, u_interpolate);
    
    
//    float2 displacedTexCoord = i.texcoord + float2(
//                                                   
//                                                   　　tex2D(_NoiseTex, i.vertex.xy/300 + float2((_Time.w%50)/50, 0)).z - .5,
//                                                   
//                                                   　　tex2D(_NoiseTex, i.vertex.xy/300 + float2(0, (_Time.w%50)/50)).z - .5
//                                                   
//                                                   　　)/20;
}

