//
//  Shaders.metal
//  Helmo
//
//  Created by Mihnea Rusu on 01/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct vertex_in_t
{
    packed_float3 position [[ attribute(0) ]];
    packed_float4 color [[ attribute(1) ]];
    packed_float2 tex_coord [[ attribute(2) ]];
    packed_float3 normal [[ attribute(3) ]];
};

struct vertex_out_t
{
    float4 position [[position]];
    float3 fragment_position;
    float4 color;
    float2 tex_coord;
    float3 normal;
};

struct light_t
{
    packed_float3 color;
    float ambient_intensity;
    packed_float3 direction;
    float diffuse_intensity;
    float shininess;
    float specular_intensity;
};

struct uniforms_t
{
    float4x4 model_matrix;
    float4x4 projection_matrix;
    light_t light;
};

/*** TUTORIAL 4 ***/

/**
    Returns the vertex after it has been transformed by the model matrix
    in 'uniforms', with the texture coordinates of the original vertex.
    Furthermore normal values are copied to the output vertex as well.
 
 
    Parameters:
        'vertex_array' - The buffer of vertices passing through the shader,
            packed as the special type vertex_in_t
        'uniforms' - The 4x4 matrix describing the model matrix
        'vid' - The id of the current vertex being processed
 */
vertex vertex_out_t basic_vertex (
    const device vertex_in_t *vertex_array [[ buffer(0) ]],
    const device uniforms_t &uniforms [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
    )
{
    float4x4 mv_matrix = uniforms.model_matrix;
    float4x4 proj_matrix = uniforms.projection_matrix;
    
    vertex_in_t v_in = vertex_array[vid];
    vertex_out_t v_out;
    v_out.position = proj_matrix * mv_matrix * float4(v_in.position, 1);
    v_out.fragment_position = (mv_matrix * float4(v_in.position, 1)).xyz;
    v_out.color = v_in.color;
    v_out.tex_coord = v_in.tex_coord;
    v_out.normal = (mv_matrix * float4(v_in.normal, 0.0)).xyz;
    
    return v_out;
}


/**
    Returns the color of the texture at that point on the interpolated vertex.
 
    Parameters:
        'interpolated' - The interpolated vertex of which we want to get the color.
 */
fragment float4 basic_fragment (
    vertex_out_t interpolated [[ stage_in ]],
    const device uniforms_t &uniforms [[ buffer(1) ]],
    texture2d<float> tex_2d [[ texture(0) ]],
    sampler sampler_2d [[ sampler(0) ]]
    )
{
    light_t light = uniforms.light;
    // Ambient light
    float4 ambient_color = float4(light.color * light.ambient_intensity, 1);
    
    // Diffuse light
    float diffuse_factor = max(0.0, dot(interpolated.normal, light.direction));
    float4 diffuse_color = float4(light.color * light.diffuse_intensity * diffuse_factor, 1.0);
    
    // Specular light
    float3 eye = normalize(interpolated.fragment_position); // Eye/camera vector
    float3 reflection = reflect(light.direction, interpolated.normal); // Reflection of specular
    float specular_factor = pow(max(0.0, dot(reflection, eye)), light.shininess); // Shininess
    float4 specular_color = float4(light.color * light.specular_intensity * specular_factor, 1.0);
    
    // Texture
    float4 color = tex_2d.sample(sampler_2d, interpolated.tex_coord);
    
    return color * (ambient_color + diffuse_color + specular_color);
}

#if 0
/*** TUTORIAL 3 ***/

/**
    Returns the vertex after it has been transformed by the model matrix
    in 'uniforms', with the texture coordinates of the original vertex.
 
    Parameters:
        'vertex_array' - The buffer of vertices passing through the shader,
            packed as the special type vertex_in_t
        'uniforms' - The 4x4 matrix describing the model matrix
        'vid' - The id of the current vertex being processed
 */
vertex vertex_out_t basic_vertex (
    const device vertex_in_t *vertex_array [[ buffer(0) ]],
    const device uniforms_t &uniforms [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
    )
{
    float4x4 mv_matrix = uniforms.model_matrix;
    float4x4 proj_matrix = uniforms.projection_matrix;
    
    vertex_in_t v_in = vertex_array[vid];
    vertex_out_t v_out;
    v_out.position = proj_matrix * mv_matrix * float4(v_in.position, 1);
    v_out.color = v_in.color;
    v_out.tex_coord = v_in.tex_coord;
    
    return v_out;
}


/**
    Returns the color of the texture at that point on the interpolated vertex.
 
    Parameters:
        'interpolated' - The interpolated vertex of which we want to get the color.
 */
fragment float4 basic_fragment (
    vertex_out_t interpolated [[ stage_in ]],
    texture2d<float> tex_2d [[ texture(0) ]],
    sampler sampler_2d [[ sampler(0) ]]
    )
{
    float4 color = tex_2d.sample(sampler_2d, interpolated.tex_coord);
    return color;
}

/*** TUTORIAL 2b ***/

/**
    Returns the vertex after it has been transformed by the model matrix
    in 'uniforms'.
 
    Parameters:
        'vertex_array' - The buffer of vertices passing through the shader,
            packed as the special type vertex_in_t
        'uniforms' - The 4x4 matrix describing the model matrix
        'vid' - The id of the current vertex being processed
*/
vertex vertex_out_t basic_vertex (
    const device vertex_in_t *vertex_array [[ buffer(0) ]],
    const device uniforms_t &uniforms [[ buffer(1) ]],
    unsigned int vid [[ vertex_id ]]
    )
{
    float4x4 mv_matrix = uniforms.model_matrix;
    float4x4 proj_matrix = uniforms.projection_matrix;
    
    vertex_in_t v_in = vertex_array[vid];
    vertex_out_t v_out;
    v_out.position = proj_matrix * mv_matrix * float4(v_in.position, 1);
    v_out.color = v_in.color;
    
    return v_out;
}


/*** TUTORIAL 2a ***/


/**
    Returns the original vertex location.
 
    Parameters:
        'vertex_array' - The buffer of vertices passing through the shader, 
            packed as the special type vertex_in_t
        'vid' - The id of the current vertex being processed
 
*/
vertex vertex_out_t basic_vertex (
    const device vertex_in_t *vertex_array [[ buffer(0) ]],
    unsigned int vid [[ vertex_id ]]
    )
{
    vertex_in_t v_in = vertex_array[vid];
    
    vertex_out_t v_out;
    v_out.position = float4(v_in.position, 1);
    v_out.color = v_in.color;
    
    return v_out;
}

/**
    Returns the color of the interpolated vertex.
    
    Parameters:
        'interpolated' - The interpolated vertex of which we want to get the color.
*/
fragment half4 basic_fragment (
    vertex_out_t interpolated [[ stage_in ]]
    )
{
    return half4(interpolated.color[0], interpolated.color[1],
                 interpolated.color[2], interpolated.color[3]);
}

/*** TUTORIAL 1 ***/

/**
    Returns the original vertex location.
 
    Parameters:
        'vertex_array' - The buffer of vertices passing through the shader
        'vid' - The id of the current vertex being processed
*/
vertex float4 basic_vertex (
    const device packed_float3 *vertex_array [[ buffer(0) ]],
    unsigned int vid [[ vertex_id ]]
    )
{
    return float4(vertex_array[vid], 1.0);
}

/**
    Returns a solid white color for every fragment.
*/
fragment half4 basic_fragment (
    void
    )
{
    return half4(1.0);
}
#endif
