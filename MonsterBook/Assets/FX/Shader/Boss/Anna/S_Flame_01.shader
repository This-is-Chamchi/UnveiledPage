// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flame_01"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_Tex_01("Tex_01", 2D) = "white" {}
		_Tex_02("Tex_02", 2D) = "white" {}
		_Silhouette_Tex("Silhouette_Tex", 2D) = "white" {}
		_Main_Tex_UV_X("Main_Tex_UV_X", Float) = 0
		_Main_Tex_UV_Y("Main_Tex_UV_Y", Float) = 0
		_Main_Pan_X("Main_Pan_X", Float) = 0
		_Main_Pan_Y("Main_Pan_Y", Float) = 0
		[Toggle]_Main_Dis_Polar_Control("Main_Dis_Polar_Control", Float) = 1
		_Main_Dis_UV_X("Main_Dis_UV_X", Float) = 1
		_Main_Dis_UV_Y("Main_Dis_UV_Y", Float) = 1
		_Main_Dis_Pan_X("Main_Dis_Pan_X", Float) = 0
		_Main_Dis_Pan_Y("Main_Dis_Pan_Y", Float) = -0.4
		_Main_Dis_Str("Main_Dis_Str", Range( 0 , 1)) = 0.3429084
		_Inner_Color("Inner_Color", Color) = (1,0.5420089,0.3820755,0)
		_Outer_Scale("Outer_Scale", Range( 0 , 1)) = 1.2159
		_Middle_Scale("Middle_Scale", Range( 0 , 5)) = 1
		_Inner_Scale("Inner_Scale", Range( 0 , 10)) = 3
		_Outer_Color("Outer_Color", Color) = (1,0.2576002,0,0)
		_Intensity("Intensity", Float) = 1
		_Dissolve_Value("Dissolve_Value", Range( 0 , 1)) = 0
		_Dissolve_Tex("Dissolve_Tex", 2D) = "white" {}
		_Line_Scale("Line_Scale", Float) = 0
		_Line_Color("Line_Color", Color) = (0,0,0,0)
		_Line_Inten("Line_Inten", Float) = 0
		[Toggle]_Dissolve_Switch("Dissolve_Switch", Float) = 0
		[Toggle]_Dissolve_Polar_Control("Dissolve_Polar_Control", Float) = 0
		_Dissolve_UV_X("Dissolve_UV_X", Float) = 0
		_Dissolve_UV_Y("Dissolve_UV_Y", Float) = 0
		_Dissolve_Pan_X("Dissolve_Pan_X", Float) = 0
		_Dissolve_Pan_Y("Dissolve_Pan_Y", Float) = 0
		_Dissolve_Dis_Str("Dissolve_Dis_Str", Range( 0 , 1)) = 0
		_Mask_Map("Mask_Map", 2D) = "white" {}
		[ASEEnd]_Mask_Dissolve_Control("Mask_Dissolve_Control", Range( -1 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord3.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower73 = abs( tex2DNode18.a );
				float saferPower34 = abs( tex2DNode18.a );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord4;
				texCoord159.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( ( saturate( step( tex2DNode11.r , pow( saferPower73 , _Inner_Scale ) ) ) * _Inner_Color ) + ( ( _Outer_Color * saturate( step( tex2DNode11.r , pow( saferPower34 , _Middle_Scale ) ) ) ) + ( _Outer_Color * temp_output_42_0 ) ) ) * _Intensity ) + ( _Line_Color * saturate( ( temp_output_151_0 - step( temp_output_179_0 , (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) ) ) ) * _Line_Inten ) ).rgb;
				float Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord2.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord2.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord3;
				texCoord159.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				float Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord3.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower73 = abs( tex2DNode18.a );
				float saferPower34 = abs( tex2DNode18.a );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord4;
				texCoord159.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( ( saturate( step( tex2DNode11.r , pow( saferPower73 , _Inner_Scale ) ) ) * _Inner_Color ) + ( ( _Outer_Color * saturate( step( tex2DNode11.r , pow( saferPower34 , _Middle_Scale ) ) ) ) + ( _Outer_Color * temp_output_42_0 ) ) ) * _Intensity ) + ( _Line_Color * saturate( ( temp_output_151_0 - step( temp_output_179_0 , (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) ) ) ) * _Line_Inten ) ).rgb;
				float Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}


		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

        
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord1;
				texCoord159.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				surfaceDescription.Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord1;
				texCoord159.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				surfaceDescription.Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
		
        Pass
        {
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

        
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


			      
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord1.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord1.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord2;
				texCoord159.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				surfaceDescription.Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}
        
			ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
        
			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

        
			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag
        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
        
			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Silhouette_Tex_ST;
			float4 _Line_Color;
			float4 _Inner_Color;
			float4 _Outer_Color;
			float _Main_Pan_X;
			float _Line_Scale;
			float _Dissolve_Value;
			float _Dissolve_Switch;
			float _Dissolve_Dis_Str;
			float _Dissolve_UV_Y;
			float _Dissolve_UV_X;
			float _Dissolve_Polar_Control;
			float _Dissolve_Pan_Y;
			float _Dissolve_Pan_X;
			float _Intensity;
			float _Middle_Scale;
			float _Line_Inten;
			float _Inner_Scale;
			float _Main_Dis_Str;
			float _Main_Dis_UV_Y;
			float _Main_Dis_UV_X;
			float _Main_Dis_Polar_Control;
			float _Main_Dis_Pan_Y;
			float _Main_Dis_Pan_X;
			float _Main_Tex_UV_Y;
			float _Main_Tex_UV_X;
			float _Main_Pan_Y;
			float _Outer_Scale;
			float _Mask_Dissolve_Control;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_01;
			sampler2D _Tex_02;
			sampler2D _Silhouette_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Mask_Map;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult87 = (float2(_Main_Pan_X , _Main_Pan_Y));
				float2 texCoord46 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner86 = ( 1.0 * _Time.y * appendResult87 + texCoord46);
				float2 appendResult112 = (float2(_Main_Tex_UV_X , _Main_Tex_UV_Y));
				float2 appendResult103 = (float2(_Main_Dis_Pan_X , _Main_Dis_Pan_Y));
				float2 CenteredUV15_g4 = ( texCoord46 - float2( 0.5,0.5 ) );
				float2 break17_g4 = CenteredUV15_g4;
				float2 appendResult23_g4 = (float2(( length( CenteredUV15_g4 ) * 1.0 * 2.0 ) , ( atan2( break17_g4.x , break17_g4.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult99 = (float2(_Main_Dis_UV_X , _Main_Dis_UV_Y));
				float2 panner102 = ( 1.0 * _Time.y * appendResult103 + ( (( _Main_Dis_Polar_Control )?( appendResult23_g4 ):( texCoord46 )) * appendResult99 ));
				float4 tex2DNode91 = tex2D( _Tex_02, panner102 );
				float4 tex2DNode11 = tex2D( _Tex_01, ( ( panner86 * appendResult112 ) + ( tex2DNode91.r * _Main_Dis_Str ) ) );
				float2 uv_Silhouette_Tex = IN.ase_texcoord1.xy * _Silhouette_Tex_ST.xy + _Silhouette_Tex_ST.zw;
				float4 tex2DNode18 = tex2D( _Silhouette_Tex, uv_Silhouette_Tex );
				float saferPower116 = abs( tex2DNode18.a );
				float temp_output_42_0 = saturate( step( tex2DNode11.r , pow( saferPower116 , _Outer_Scale ) ) );
				float2 appendResult172 = (float2(_Dissolve_Pan_X , _Dissolve_Pan_Y));
				float2 CenteredUV15_g5 = ( IN.ase_texcoord1.xy - float2( 0.5,0.5 ) );
				float2 break17_g5 = CenteredUV15_g5;
				float2 appendResult23_g5 = (float2(( length( CenteredUV15_g5 ) * 1.0 * 2.0 ) , ( atan2( break17_g5.x , break17_g5.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult168 = (float2(_Dissolve_UV_X , _Dissolve_UV_Y));
				float2 panner171 = ( 1.0 * _Time.y * appendResult172 + ( (( _Dissolve_Polar_Control )?( appendResult23_g5 ):( texCoord46 )) * appendResult168 ));
				float temp_output_179_0 = (0.0 + (tex2D( _Dissolve_Tex, ( panner171 + ( tex2DNode91.r * _Dissolve_Dis_Str ) ) ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
				float4 texCoord159 = IN.ase_texcoord2;
				texCoord159.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_151_0 = step( temp_output_179_0 , ( (( _Dissolve_Switch )?( texCoord159.z ):( _Dissolve_Value )) + _Line_Scale ) );
				
				surfaceDescription.Alpha = ( ( temp_output_42_0 * temp_output_151_0 ) * ( 1.0 - step( ( tex2DNode11.r - ( 1.0 - tex2D( _Mask_Map, ( (float2( 2,2 ) + (texCoord46 - float2( -1,-1 )) * (float2( 1,1 ) - float2( 2,2 )) / (float2( 0,0 ) - float2( -1,-1 ))) + _Mask_Dissolve_Control ) ).r ) ) , 0.0 ) ) );
				surfaceDescription.AlphaClipThreshold = 0.5;
				
				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}

			ENDHLSL
        }
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
2242;277;1171;420;2642.375;13.60249;3.281802;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2704.025,-350.3185;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;107;-568.4318,-958.258;Inherit;False;520.4399;648.2827;Textures;6;67;109;29;66;28;108;Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-2247.009,23.92323;Inherit;False;Property;_Main_Dis_UV_Y;Main_Dis_UV_Y;9;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2246.813,-48.59291;Inherit;False;Property;_Main_Dis_UV_X;Main_Dis_UV_X;8;0;Create;True;0;0;0;False;0;False;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;96;-2476.862,-156.7818;Inherit;False;Polar Coordinates;-1;;4;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-2165.008,100.9232;Inherit;False;Property;_Main_Dis_Pan_X;Main_Dis_Pan_X;10;0;Create;True;0;0;0;False;0;False;0;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2165.008,171.9232;Inherit;False;Property;_Main_Dis_Pan_Y;Main_Dis_Pan_Y;11;0;Create;True;0;0;0;False;0;False;-0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;106;-2115.871,-148.8868;Inherit;False;Property;_Main_Dis_Polar_Control;Main_Dis_Polar_Control;7;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;-2014.996,-30.36158;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;108;-527.0572,-712.4907;Inherit;True;Property;_Tex_02;Tex_02;1;0;Create;True;0;0;0;False;0;False;4a9f4408994abdb44bcb77d8943d338c;4a9f4408994abdb44bcb77d8943d338c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1850.397,-112.4845;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;165;-1285.025,388.7632;Inherit;False;Polar Coordinates;-1;;5;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1881.466,-273.7287;Inherit;False;Property;_Main_Pan_X;Main_Pan_X;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-982.1777,504.8852;Inherit;False;Property;_Dissolve_UV_Y;Dissolve_UV_Y;27;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-262.8896,-712.2043;Inherit;False;Tex_02;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1880.466,-197.7285;Inherit;False;Property;_Main_Pan_Y;Main_Pan_Y;6;0;Create;True;0;0;0;False;0;False;0;-0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-981.1777,429.8852;Inherit;False;Property;_Dissolve_UV_X;Dissolve_UV_X;26;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;-1980.011,126.9232;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-1682.466,-247.7286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1705.032,-90.63232;Inherit;False;109;Tex_02;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1517.341,-140.8022;Inherit;False;Property;_Main_Tex_UV_Y;Main_Tex_UV_Y;4;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;168;-792.1777,454.8852;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;102;-1707.011,-20.0768;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-1517.341,-211.8629;Inherit;False;Property;_Main_Tex_UV_X;Main_Tex_UV_X;3;0;Create;True;0;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-528.7374,-510.9655;Inherit;True;Property;_Silhouette_Tex;Silhouette_Tex;2;0;Create;True;0;0;0;False;0;False;6ae08ea512cb5ac42a33d2dc1a9df060;6ae08ea512cb5ac42a33d2dc1a9df060;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;174;-819.1777,657.8852;Inherit;False;Property;_Dissolve_Pan_Y;Dissolve_Pan_Y;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-819.1777,581.8852;Inherit;False;Property;_Dissolve_Pan_X;Dissolve_Pan_X;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;166;-946.0167,317.4218;Inherit;False;Property;_Dissolve_Polar_Control;Dissolve_Polar_Control;25;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-264.8497,-509.9198;Inherit;False;Silhouette;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-348.6688,1459.033;Inherit;False;Property;_Mask_Dissolve_Control;Mask_Dissolve_Control;32;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;112;-1336.554,-184.6926;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;187;-352.1404,1230.652;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;-1,-1;False;2;FLOAT2;0,0;False;3;FLOAT2;2,2;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-635.1777,603.8852;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1485.376,129.7585;Inherit;False;Property;_Main_Dis_Str;Main_Dis_Str;12;0;Create;True;0;0;0;False;0;False;0.3429084;0.473;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-621.1777,386.8852;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;177;-974.769,872.5286;Inherit;False;Property;_Dissolve_Dis_Str;Dissolve_Dis_Str;30;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;66;-529.5551,-909.2695;Inherit;True;Property;_Tex_01;Tex_01;0;0;Create;True;0;0;0;False;0;False;a27c1c84f85235640847eedf4a8d7ad9;a27c1c84f85235640847eedf4a8d7ad9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;86;-1483.466,-348.7288;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;91;-1505.376,-56.24153;Inherit;True;Property;_Main_Dis_Tex;Main_Dis_Tex;10;0;Create;True;0;0;0;False;0;False;-1;4a9f4408994abdb44bcb77d8943d338c;4a9f4408994abdb44bcb77d8943d338c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;94;-1066.143,-66.20435;Inherit;False;29;Silhouette;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;-37.82715,1282.969;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-1197.568,-259.9334;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-262.8488,-909.0109;Inherit;False;Tex_01;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1191.408,46.75846;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-603.769,830.5286;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;171;-452.1777,437.8852;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;159;-336.1841,995.2697;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1064.408,-157.2415;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-410.7785,892.0502;Inherit;False;Property;_Dissolve_Value;Dissolve_Value;19;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-518.8458,165.6797;Inherit;False;Property;_Outer_Scale;Outer_Scale;14;0;Create;True;0;0;0;False;0;False;1.2159;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-868.2836,10.0127;Inherit;True;Property;_Main_Silhouette;Main_Silhouette;1;0;Create;True;0;0;0;False;0;False;-1;6ae08ea512cb5ac42a33d2dc1a9df060;6ae08ea512cb5ac42a33d2dc1a9df060;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1065.238,-231.2128;Inherit;False;67;Tex_01;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;186;152.8124,1229.169;Inherit;True;Property;_Mask_Map;Mask_Map;31;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;164;-225.0858,660.8593;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;196;493.075,1208.711;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;38.59146,1107.813;Inherit;False;Property;_Line_Scale;Line_Scale;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;158;-33.02654,972.3748;Inherit;False;Property;_Dissolve_Switch;Dissolve_Switch;24;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;116;-212.395,146.44;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;147;-72.38977,535.8629;Inherit;True;Property;_Dissolve_Tex;Dissolve_Tex;20;0;Create;True;0;0;0;False;0;False;-1;None;a27c1c84f85235640847eedf4a8d7ad9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-865.359,-185.6431;Inherit;True;Property;_Main_Tex;Main_Tex;0;0;Create;True;0;0;0;False;0;False;-1;a27c1c84f85235640847eedf4a8d7ad9;a27c1c84f85235640847eedf4a8d7ad9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;250.0525,1048.163;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;179;251.5562,742.4291;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;197;707.075,1143.181;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;59;84.42479,151.7363;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;198;966.7469,1164.769;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;42;356.4297,152.1708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;151;470.3511,843.5453;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;1733.721,415.6013;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;199;1215.747,1140.769;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;1139.081,-14.43523;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;864.7889,9.152305;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;154;756.351,743.5539;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;2054.188,679.703;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;79;359.8325,-290.8309;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;587.8323,-288.8308;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;80;82.17138,-637.7988;Inherit;False;Property;_Inner_Color;Inner_Color;13;0;Create;True;0;0;0;False;0;False;1,0.5420089,0.3820755,0;1,0.4079272,0.2028301,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;157;812.2855,952.7894;Inherit;False;Property;_Line_Inten;Line_Inten;23;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-520.6284,-272.9981;Inherit;False;Property;_Inner_Scale;Inner_Scale;16;0;Create;True;0;0;0;False;0;False;3;10;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;149;468.7224,629.218;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;355.7131,-67.22903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-517.9861,-55.62207;Inherit;False;Property;_Middle_Scale;Middle_Scale;15;0;Create;True;0;0;0;False;0;False;1;2.6;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;61;83.22456,-67.12239;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;1421.931,68.86782;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;81.42265,-467.5072;Inherit;False;Property;_Outer_Color;Outer_Color;17;0;Create;True;0;0;0;False;0;False;1,0.2576002,0,0;1,0.1450825,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;156;711.1204,577.8187;Inherit;False;Property;_Line_Color;Line_Color;22;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.6133298,0.3726414,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;1205.568,198.093;Inherit;False;Property;_Intensity;Intensity;18;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;588.7644,129.4267;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;76;80.97428,-291.095;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;588.7783,-90.69549;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;34;-210.6263,-74.34593;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;73;-209.2138,-292.2802;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;1731.667,195.5888;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;160;969.6691,774.8981;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;1190.285,717.2894;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;592.1232,426.8439;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;2457.427,452.483;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;Flame_01;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;638027879113125238;  Blend;0;0;Two Sided;0;638050679830899128;Cast Shadows;0;638027879141817856;  Use Shadow Threshold;0;0;Receive Shadows;0;638027879147814285;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;96;1;46;0
WireConnection;106;0;46;0
WireConnection;106;1;96;0
WireConnection;99;0;100;0
WireConnection;99;1;101;0
WireConnection;97;0;106;0
WireConnection;97;1;99;0
WireConnection;109;0;108;0
WireConnection;103;0;104;0
WireConnection;103;1;105;0
WireConnection;87;0;88;0
WireConnection;87;1;89;0
WireConnection;168;0;169;0
WireConnection;168;1;170;0
WireConnection;102;0;97;0
WireConnection;102;2;103;0
WireConnection;166;0;46;0
WireConnection;166;1;165;0
WireConnection;29;0;28;0
WireConnection;112;0;113;0
WireConnection;112;1;114;0
WireConnection;187;0;46;0
WireConnection;172;0;173;0
WireConnection;172;1;174;0
WireConnection;167;0;166;0
WireConnection;167;1;168;0
WireConnection;86;0;46;0
WireConnection;86;2;87;0
WireConnection;91;0;110;0
WireConnection;91;1;102;0
WireConnection;191;0;187;0
WireConnection;191;1;192;0
WireConnection;111;0;86;0
WireConnection;111;1;112;0
WireConnection;67;0;66;0
WireConnection;92;0;91;1
WireConnection;92;1;93;0
WireConnection;176;0;91;1
WireConnection;176;1;177;0
WireConnection;171;0;167;0
WireConnection;171;2;172;0
WireConnection;90;0;111;0
WireConnection;90;1;92;0
WireConnection;18;0;94;0
WireConnection;186;1;191;0
WireConnection;164;0;171;0
WireConnection;164;1;176;0
WireConnection;196;0;186;1
WireConnection;158;0;150;0
WireConnection;158;1;159;3
WireConnection;116;0;18;4
WireConnection;116;1;22;0
WireConnection;147;1;164;0
WireConnection;11;0;68;0
WireConnection;11;1;90;0
WireConnection;152;0;158;0
WireConnection;152;1;153;0
WireConnection;179;0;147;1
WireConnection;197;0;11;1
WireConnection;197;1;196;0
WireConnection;59;0;11;1
WireConnection;59;1;116;0
WireConnection;198;0;197;0
WireConnection;42;0;59;0
WireConnection;151;0;179;0
WireConnection;151;1;152;0
WireConnection;161;0;42;0
WireConnection;161;1;151;0
WireConnection;199;0;198;0
WireConnection;83;0;77;0
WireConnection;83;1;44;0
WireConnection;44;0;39;0
WireConnection;44;1;24;0
WireConnection;154;0;151;0
WireConnection;154;1;149;0
WireConnection;200;0;161;0
WireConnection;200;1;199;0
WireConnection;79;0;76;0
WireConnection;77;0;79;0
WireConnection;77;1;80;0
WireConnection;149;0;179;0
WireConnection;149;1;158;0
WireConnection;43;0;61;0
WireConnection;61;0;11;1
WireConnection;61;1;34;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;24;0;23;0
WireConnection;24;1;42;0
WireConnection;76;0;11;1
WireConnection;76;1;73;0
WireConnection;39;0;23;0
WireConnection;39;1;43;0
WireConnection;34;0;18;4
WireConnection;34;1;36;0
WireConnection;73;0;18;4
WireConnection;73;1;71;0
WireConnection;163;0;84;0
WireConnection;163;1;155;0
WireConnection;160;0;154;0
WireConnection;155;0;156;0
WireConnection;155;1;160;0
WireConnection;155;2;157;0
WireConnection;2;2;163;0
WireConnection;2;3;200;0
ASEEND*/
//CHKSM=B8A6A5E77BB0260B4FEEDD94CAF075BC01861694