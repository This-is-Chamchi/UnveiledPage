// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/MasterR&D"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_inten("inten", Float) = 1
		_MainStr("MainStr", Float) = 1
		_Main_Tex("Main_Tex", 2D) = "white" {}
		[Toggle]_Polar("Polar", Float) = 0
		[Toggle]_Main_Panning("Main_Panning", Float) = 1
		_PanCtrl("PanCtrl", Vector) = (0,0,0,0)
		[Toggle]_PanTimeCustomX("PanTimeCustom(X)", Float) = 1
		[Toggle]_Dissolve("Dissolve", Float) = 0
		_DissolveStr("DissolveStr", Range( -2 , 1)) = -1
		[Toggle]_DissovleStrCustomY("DissovleStrCustom(Y)", Float) = 1
		_Dissolve_Tex("Dissolve_Tex", 2D) = "white" {}
		[Toggle]_DissolvePolar("DissolvePolar", Float) = 0
		_PolarLengthh("PolarLengthh", Float) = 1
		[Toggle]_Dissolve_Panning("Dissolve_Panning", Float) = 1
		_DissolvePanCtrl("DissolvePanCtrl", Vector) = (0,0,0,0)
		[Toggle]_DissolveMaskVer("DissolveMaskVer", Float) = 0
		[Toggle]_DissolveMaskDirection("DissolveMaskDirection", Float) = 0
		_DissolveMaskCtrlZ("DissolveMaskCtrl(Z)", Vector) = (0,0,0,0)
		_DissolveMaskPow("DissolveMaskPow", Float) = 6.21
		[Toggle]_Distortion("Distortion", Float) = 0
		_DistortionStr("DistortionStr", Float) = 0
		_Distortion_Tex("Distortion_Tex", 2D) = "white" {}
		[Toggle]_DistortionPolar("DistortionPolar", Float) = 0
		_PolarLength("PolarLength", Float) = 1
		[Toggle]_Distortion_Panning("Distortion_Panning", Float) = 0
		_DistortionPanCtrl("DistortionPanCtrl", Vector) = (0,0,0,0)
		[Toggle]_MaskDirectionY("MaskDirectionY", Float) = 0
		[Toggle]_MaskDirectionX("MaskDirectionX", Float) = 0
		[Toggle]_MaskTexture("MaskTexture", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskTexStr("MaskTexStr", Range( 0 , 10)) = 1
		[Toggle]_Toon("Toon", Float) = 0
		[ASEEnd]_DepthFade("DepthFade", Float) = 0
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
			#define REQUIRE_DEPTH_TEXTURE 1

			
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


			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_color = v.ase_color;
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
				float4 ase_color : COLOR;
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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord3.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord3.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord4;
				texCoord21.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord3.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord3.xy.x * ( 1.0 - IN.ase_texcoord3.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * ( _inten * 0.5 ) * (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) ).rgb;
				float Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1

			
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
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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

				float2 uv_Main_Tex = IN.ase_texcoord2.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord2.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord3;
				texCoord21.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord2.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord2.xy.x * ( 1.0 - IN.ase_texcoord2.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				float Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord2.xy.y * ( 1.0 - IN.ase_texcoord2.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord2.xy.y * ( 1.0 - IN.ase_texcoord2.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord2.xy.y * ( 1.0 - IN.ase_texcoord2.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord2.xy.y * ( 1.0 - IN.ase_texcoord2.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1

			
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


			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_color = v.ase_color;
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
				float4 ase_color : COLOR;
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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord3.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord3.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord4;
				texCoord21.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord3.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord3.xy.x * ( 1.0 - IN.ase_texcoord3.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * ( _inten * 0.5 ) * (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) ).rgb;
				float Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord3.xy.y * ( 1.0 - IN.ase_texcoord3.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1

        
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
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


				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord1;
				texCoord21.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord.xy.x * ( 1.0 - IN.ase_texcoord.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				surfaceDescription.Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1


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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
        
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


				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord1;
				texCoord21.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord.xy.x * ( 1.0 - IN.ase_texcoord.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				surfaceDescription.Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord.xy.y * ( 1.0 - IN.ase_texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1

			
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			      
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

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord1.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord1.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord2;
				texCoord21.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord1.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord1.xy.x * ( 1.0 - IN.ase_texcoord1.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				surfaceDescription.Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
			#define REQUIRE_DEPTH_TEXTURE 1

        
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _PanCtrl;
			float4 _MaskTex_ST;
			float4 _DistortionPanCtrl;
			float4 _DissolveMaskCtrlZ;
			float4 _Distortion_Tex_ST;
			float4 _DissolvePanCtrl;
			float4 _Main_Tex_ST;
			float4 _Dissolve_Tex_ST;
			float _DissolveMaskVer;
			float _Dissolve_Panning;
			float _DissolvePolar;
			float _PolarLengthh;
			float _DissovleStrCustomY;
			float _DissolveStr;
			float _DissolveMaskDirection;
			float _DissolveMaskPow;
			float _MainStr;
			float _inten;
			float _PanTimeCustomX;
			float _PolarLength;
			float _DistortionPolar;
			float _Distortion_Panning;
			float _DistortionStr;
			float _Polar;
			float _Distortion;
			float _Main_Panning;
			float _Dissolve;
			float _MaskDirectionY;
			float _MaskDirectionX;
			float _MaskTexture;
			float _Toon;
			float _MaskTexStr;
			float _DepthFade;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Main_Tex;
			sampler2D _Distortion_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
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

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
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
				float4 ase_color : COLOR;

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
				o.ase_color = v.ase_color;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
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
				float2 uv_Main_Tex = IN.ase_texcoord1.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 CenteredUV15_g7 = ( uv_Main_Tex - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 uv_Distortion_Tex = IN.ase_texcoord1.xy * _Distortion_Tex_ST.xy + _Distortion_Tex_ST.zw;
				float2 CenteredUV15_g1 = ( uv_Distortion_Tex - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / TWO_PI ) * _PolarLength )));
				float mulTime37 = _TimeParameters.x * _DistortionPanCtrl.z;
				float2 appendResult36 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner39 = ( ( mulTime37 + _DistortionPanCtrl.w ) * appendResult36 + (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )));
				float mulTime27 = _TimeParameters.x * _PanCtrl.z;
				float4 texCoord21 = IN.ase_texcoord2;
				texCoord21.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl73 = texCoord21.x;
				float2 appendResult25 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner18 = ( (( _PanTimeCustomX )?( PanTimeCtrl73 ):( ( mulTime27 + _PanCtrl.w ) )) * appendResult25 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )));
				float temp_output_66_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner18 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner39 ):( (( _DistortionPolar )?( appendResult23_g1 ):( uv_Distortion_Tex )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) ) ):( (( _Polar )?( appendResult23_g7 ):( uv_Main_Tex )) )) )) ).r * _MainStr );
				float2 uv_Dissolve_Tex = IN.ase_texcoord1.xy * _Dissolve_Tex_ST.xy + _Dissolve_Tex_ST.zw;
				float2 CenteredUV15_g8 = ( uv_Dissolve_Tex - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / TWO_PI ) * _PolarLengthh )));
				float mulTime43 = _TimeParameters.x * _DissolvePanCtrl.z;
				float2 appendResult42 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime43 + _DissolvePanCtrl.w ) * appendResult42 + (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )));
				float4 tex2DNode30 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( uv_Dissolve_Tex )) )) );
				float DissolveStrCustom77 = texCoord21.y;
				float mulTime152 = _TimeParameters.x * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr78 = texCoord21.z;
				float2 appendResult157 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord148 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner154 = ( ( mulTime152 + DissolveMaskStr78 ) * appendResult157 + texCoord148);
				float2 break155 = panner154;
				float lerpResult137 = lerp( tex2DNode30.r , (( _DissolveMaskDirection )?( break155.y ):( break155.x )) , _DissolveMaskPow);
				float temp_output_161_0 = ( 1.0 - lerpResult137 );
				float temp_output_96_0 = (0.0 + (( IN.ase_texcoord1.xy.x * ( 1.0 - IN.ase_texcoord1.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth60 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth60 = saturate( abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) ) );
				
				surfaceDescription.Alpha = ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_96_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.ase_texcoord1.xy.y * ( 1.0 - IN.ase_texcoord1.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_66_0 - (( _DissolveMaskVer )?( temp_output_161_0 ):( ( tex2DNode30.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom77 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_66_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_66_0 )) )) )) )) )) * IN.ase_color.a * distanceDepth60 );
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
0;0;1920;1011;-1623.78;530.7325;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;47;-3297.619,-467.4709;Inherit;False;1450.268;460.3232;UVDistortion;12;50;32;34;39;68;65;36;69;37;38;35;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;35;-3232.885,-185.0144;Inherit;False;Property;_DistortionPanCtrl;DistortionPanCtrl;25;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;167;-3152.784,-275.4205;Inherit;False;Property;_PolarLength;PolarLength;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-3251.568,-438.7325;Inherit;False;0;32;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;37;-2990.973,-137.2995;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;69;-2982.977,-364.0164;Inherit;False;Polar Coordinates;-1;;1;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-2751.866,-108.5892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;68;-2748.563,-421.9574;Inherit;False;Property;_DistortionPolar;DistortionPolar;22;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2824.792,-224.0614;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;104;-1585.658,-767.287;Inherit;False;589.4069;433.9417;Custom;5;21;73;77;78;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;39;-2632.809,-206.3602;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1961.744,652.9777;Inherit;False;1370.011;487.8423;Dissolve;15;44;43;42;30;45;40;41;53;62;64;70;71;81;80;168;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1535.658,-645.4213;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-1234.004,-542.7353;Inherit;False;DissolveMaskStr;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;34;-2440.365,-303.4852;Inherit;False;Property;_Distortion_Panning;Distortion_Panning;24;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-2161.427,26.20602;Inherit;False;0;15;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;168;-1895.383,842.673;Inherit;False;Property;_PolarLengthh;PolarLengthh;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;156;-1584.846,1340.939;Inherit;False;Property;_DissolveMaskCtrlZ;DissolveMaskCtrl(Z);17;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-1934.325,694.2897;Inherit;False;0;30;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;41;-1911.744,931.8199;Inherit;False;Property;_DissolvePanCtrl;DissolvePanCtrl;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;-1,0,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;28;-1657.657,315.0917;Inherit;False;Property;_PanCtrl;PanCtrl;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1380.029,1491.184;Inherit;False;78;DissolveMaskStr;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;43;-1582.938,1002.901;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-2168.95,-285.758;Inherit;True;Property;_Distortion_Tex;Distortion_Tex;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;152;-1361.556,1417.556;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-1929.044,99.05051;Inherit;False;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2091.353,-450.9916;Inherit;False;Property;_DistortionStr;DistortionStr;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;71;-1700.709,764.9831;Inherit;False;Polar Coordinates;-1;;8;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-1184.949,1411.616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1716.231,-241.5762;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-1433.961,416.1868;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1449.842,692.6879;Inherit;False;Property;_DissolvePolar;DissolvePolar;11;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;76;-1707.63,23.1095;Inherit;False;Property;_Polar;Polar;3;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;148;-1408.203,1201.831;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;157;-1349.846,1321.345;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1226.813,-717.287;Inherit;False;PanTimeCtrl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1404.306,1029.136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-1505.639,896.3869;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;154;-1119.352,1289.291;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1247.451,-632.2708;Inherit;False;DissolveStrCustom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-1441.373,538.7111;Inherit;False;73;PanTimeCtrl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-1270.95,421.9449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1315.808,-152.4323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;45;-1313.656,914.0883;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-1239.637,323.1487;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;155;-939.491,1202.822;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ToggleSwitchNode;74;-1135.479,443.5436;Inherit;False;Property;_PanTimeCustomX;PanTimeCustom(X);6;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1075.203,942.6729;Inherit;False;Property;_DissolveStr;DissolveStr;8;0;Create;True;0;0;0;False;0;False;-1;-0.52;-2;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-1133.698,718.1737;Inherit;False;Property;_Dissolve_Panning;Dissolve_Panning;13;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1269.26,1053.375;Inherit;False;77;DissolveStrCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;33;-1267.6,65.30674;Inherit;False;Property;_Distortion;Distortion;19;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;81;-1034.813,1023.135;Inherit;False;Property;_DissovleStrCustomY;DissovleStrCustom(Y);9;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-913.3332,703.8494;Inherit;True;Property;_Dissolve_Tex;Dissolve_Tex;10;0;Create;True;0;0;0;False;0;False;-1;None;20c0b0cb78525ae45af8eb078147784a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-437.2972,1222.506;Inherit;False;Property;_DissolveMaskPow;DissolveMaskPow;18;0;Create;True;0;0;0;False;0;False;6.21;6.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;140;-761.3057,1200.643;Inherit;True;Property;_DissolveMaskDirection;DissolveMaskDirection;16;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;18;-933.6541,315.8501;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;137;-251.279,948.395;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;19;-935.2122,112.4894;Inherit;False;Property;_Main_Panning;Main_Panning;4;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;62;-763.5271,910.9775;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-983.0258,-1131.467;Inherit;False;1488.185;789.6182;Mask;21;124;123;121;122;118;96;92;91;83;90;82;101;97;98;99;100;111;116;127;128;163;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-493.9385,723.5346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;161;-18.46379,951.202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-531.7323,336.6227;Inherit;False;Property;_MainStr;MainStr;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-929.3416,-629.2308;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-646.5851,128.5414;Inherit;True;Property;_Main_Tex;Main_Tex;2;0;Create;True;0;0;0;False;0;False;-1;None;3a0b5bfc117d6494b82e55b6d533afad;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;147;-357.0491,816.6555;Inherit;True;Property;_DissolveMaskVer;DissolveMaskVer;15;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;101;-691.2112,-469.3341;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-303.6411,156.8602;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-484.0164,-478.3159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;97;-690.0029,-555.4203;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-197.5004,600.2903;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-346.9708,-554.2043;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;57;51.99263,564.5009;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;59;283.9115,505.5625;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;100;-189.6428,-584.3154;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;31;35.89084,171.7664;Inherit;False;Property;_Dissolve;Dissolve;7;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;116;275.4735,-374.4018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;444.6616,-236.466;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;114;667.4778,-284.2522;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;90;-688.2101,-728.7133;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;113;539.478,-337.0522;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;198.522,-268.7412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-448.9214,-763.3707;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;83;-676.3038,-829.5949;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;102;563.8843,-473.2518;Inherit;False;Property;_MaskDirectionY;MaskDirectionY;26;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-453.6904,-945.3161;Inherit;False;Property;_MaskTexStr;MaskTexStr;30;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;118;-742.3595,-1062.718;Inherit;True;Property;_MaskTex;MaskTex;29;0;Create;True;0;0;0;False;0;False;118;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;112;774.1184,-501.2361;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-340.0872,-806.251;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;124;150.1482,-834.2311;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;123;-215.7691,-937.6191;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-334.6904,-1049.316;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;111;368.3454,-562.1302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;96;-180.3493,-828.0081;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;125;91.17774,-91.9174;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;660.5372,-717.6379;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-137.0075,-1051.41;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;922.7594,-586.8702;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;122;217.6064,-1033.504;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;119;798.3532,-244.118;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;108;970.9229,-121.9899;Inherit;False;Property;_MaskDirectionX;MaskDirectionX;27;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;126;1166.469,-772.4519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;115;1241.275,-124.6677;Inherit;True;Property;_MaskTexture;MaskTexture;28;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;1489.31,-151.6841;Inherit;False;Constant;_ToonStr;ToonStr;26;0;Create;True;0;0;0;False;0;False;0.7;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;129;1642.539,-327.9508;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;131;1868.874,-320.8818;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;2353.82,292.9608;Inherit;False;Property;_DepthFade;DepthFade;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;132;2095.623,-24.18563;Inherit;False;Property;_Toon;Toon;31;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;60;2562.113,240.9607;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;133;2282.296,148.4826;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;11;2344.465,-72.37212;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;136;2344.751,137.4614;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;106;-2380.989,27.06095;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-2386.062,121.4204;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;105;-2598.961,34.87785;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;0;False;0;False;1,2,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;2787.732,-73.92073;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;100.8098,-728.5787;Inherit;False;MaskTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-1240.217,-448.7452;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;146;127.2512,898.2634;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;2663.78,-182.7325;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;2494.78,-128.7325;Inherit;False;Constant;_Float0;Float 0;33;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;2783.702,112.6962;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;2519.636,-206.2353;Inherit;False;Property;_inten;inten;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2855.927,140.6007;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;3148.025,88.93739;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;Custom/MasterR&D;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;638023834785723175;  Blend;0;0;Two Sided;0;637997630598478626;Cast Shadows;0;637997630606860054;  Use Shadow Threshold;0;0;Receive Shadows;0;637997630613328417;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;37;0;35;3
WireConnection;69;1;38;0
WireConnection;69;4;167;0
WireConnection;65;0;37;0
WireConnection;65;1;35;4
WireConnection;68;0;38;0
WireConnection;68;1;69;0
WireConnection;36;0;35;1
WireConnection;36;1;35;2
WireConnection;39;0;68;0
WireConnection;39;2;36;0
WireConnection;39;1;65;0
WireConnection;78;0;21;3
WireConnection;34;0;68;0
WireConnection;34;1;39;0
WireConnection;43;0;41;3
WireConnection;32;1;34;0
WireConnection;152;0;156;3
WireConnection;75;1;16;0
WireConnection;71;1;44;0
WireConnection;71;4;168;0
WireConnection;159;0;152;0
WireConnection;159;1;164;0
WireConnection;49;0;50;0
WireConnection;49;1;32;1
WireConnection;27;0;28;3
WireConnection;70;0;44;0
WireConnection;70;1;71;0
WireConnection;76;0;16;0
WireConnection;76;1;75;0
WireConnection;157;0;156;1
WireConnection;157;1;156;2
WireConnection;73;0;21;1
WireConnection;64;0;43;0
WireConnection;64;1;41;4
WireConnection;42;0;41;1
WireConnection;42;1;41;2
WireConnection;154;0;148;0
WireConnection;154;2;157;0
WireConnection;154;1;159;0
WireConnection;77;0;21;2
WireConnection;63;0;27;0
WireConnection;63;1;28;4
WireConnection;48;0;49;0
WireConnection;48;1;76;0
WireConnection;45;0;70;0
WireConnection;45;2;42;0
WireConnection;45;1;64;0
WireConnection;25;0;28;1
WireConnection;25;1;28;2
WireConnection;155;0;154;0
WireConnection;74;0;63;0
WireConnection;74;1;72;0
WireConnection;40;0;70;0
WireConnection;40;1;45;0
WireConnection;33;0;76;0
WireConnection;33;1;48;0
WireConnection;81;0;53;0
WireConnection;81;1;80;0
WireConnection;30;1;40;0
WireConnection;140;0;155;0
WireConnection;140;1;155;1
WireConnection;18;0;33;0
WireConnection;18;2;25;0
WireConnection;18;1;74;0
WireConnection;137;0;30;1
WireConnection;137;1;140;0
WireConnection;137;2;145;0
WireConnection;19;0;33;0
WireConnection;19;1;18;0
WireConnection;62;0;81;0
WireConnection;52;0;30;1
WireConnection;52;1;62;0
WireConnection;161;0;137;0
WireConnection;15;1;19;0
WireConnection;147;0;52;0
WireConnection;147;1;161;0
WireConnection;101;0;82;2
WireConnection;66;0;15;1
WireConnection;66;1;67;0
WireConnection;98;0;101;0
WireConnection;97;0;82;2
WireConnection;56;0;66;0
WireConnection;56;1;147;0
WireConnection;99;0;97;0
WireConnection;99;1;98;0
WireConnection;57;0;56;0
WireConnection;57;4;66;0
WireConnection;59;0;57;0
WireConnection;100;0;99;0
WireConnection;31;0;66;0
WireConnection;31;1;59;0
WireConnection;116;0;100;0
WireConnection;89;0;116;0
WireConnection;89;1;31;0
WireConnection;114;0;89;0
WireConnection;90;0;82;1
WireConnection;113;0;114;0
WireConnection;117;0;31;0
WireConnection;91;0;90;0
WireConnection;83;0;82;1
WireConnection;102;0;117;0
WireConnection;102;1;113;0
WireConnection;112;0;102;0
WireConnection;92;0;83;0
WireConnection;92;1;91;0
WireConnection;124;0;31;0
WireConnection;123;0;124;0
WireConnection;127;0;118;1
WireConnection;127;1;128;0
WireConnection;111;0;112;0
WireConnection;96;0;92;0
WireConnection;125;0;31;0
WireConnection;110;0;96;0
WireConnection;110;1;111;0
WireConnection;121;0;127;0
WireConnection;121;1;123;0
WireConnection;120;0;110;0
WireConnection;122;0;121;0
WireConnection;122;4;125;0
WireConnection;119;0;102;0
WireConnection;108;0;119;0
WireConnection;108;1;120;0
WireConnection;126;0;122;0
WireConnection;115;0;108;0
WireConnection;115;1;126;0
WireConnection;129;0;115;0
WireConnection;129;1;130;0
WireConnection;131;0;129;0
WireConnection;132;0;115;0
WireConnection;132;1;131;0
WireConnection;60;0;61;0
WireConnection;133;0;132;0
WireConnection;136;0;132;0
WireConnection;106;0;105;1
WireConnection;106;1;105;2
WireConnection;107;0;105;3
WireConnection;107;1;105;4
WireConnection;12;0;11;0
WireConnection;12;1;169;0
WireConnection;12;2;136;0
WireConnection;163;0;96;0
WireConnection;146;0;161;0
WireConnection;169;0;13;0
WireConnection;169;1;170;0
WireConnection;14;0;133;0
WireConnection;14;1;11;4
WireConnection;14;2;60;0
WireConnection;2;2;12;0
WireConnection;2;3;14;0
ASEEND*/
//CHKSM=B703CF74314AB6CEDA96F7A5EECDD5B5A8FF23BA