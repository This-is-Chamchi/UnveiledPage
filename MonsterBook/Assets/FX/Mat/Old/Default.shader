// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Default"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_MainTex("MainTex", 2D) = "white" {}
		_MainTex_inten("MainTex_inten", Float) = 1
		_MainTexTilingOffset("MainTexTilingOffset", Vector) = (1,1,0,0)
		[Toggle]_MainTexTIlingCustom2XY("MainTexTIling(Custom2XY))", Float) = 0
		_MainTexPanDirecCustomX("MainTexPanDirec(CustomX)", Vector) = (0,0,0,0)
		_inten("inten", Float) = 1
		[Toggle]_IntenCustomCustomZ("IntenCustom(CustomZ)", Float) = 0
		[Toggle]_dissolve("dissolve", Float) = 0
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_DissolveStr("DissolveStr", Float) = 1
		[Toggle]_DissolveStrCustomCustomY("DissolveStrCustom(CustomY)", Float) = 0
		[Toggle]_UVDistortion("UVDistortion", Float) = 0
		_UVDistotionTex("UVDistotionTex", 2D) = "white" {}
		_UVDistortTileOffset("UVDistortTileOffset", Vector) = (1,1,0,0)
		_UVDistortPanZtime("UVDistortPan(Ztime)", Vector) = (0,0,0,0)
		_DistortionStr("DistortionStr", Float) = 0
		[Toggle]_Mask("Mask", Float) = 0
		_MaskStr("MaskStr", Float) = 13.75
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskPan("MaskPan", Vector) = (1,1,0,0)
		[Toggle]_MaskStrCustomW("MaskStr(CustomW)", Float) = 0
		[Toggle]_MaskPanCustom2zw("MaskPan(Custom2zw)", Float) = 0
		[ASEEnd]_depth("depth", Float) = 0
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
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest Always
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord6 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord3;
				texCoord11.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord5;
				texCoord76.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord4.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord4.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord4.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord4.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord4.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float IntenCustom69 = texCoord11.z;
				
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * temp_output_60_0 * (( _IntenCustomCustomZ )?( IntenCustom69 ):( _inten )) ).rgb;
				float Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord5 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord2;
				
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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

				float4 texCoord11 = IN.ase_texcoord2;
				texCoord11.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord4;
				texCoord76.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord3.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord3.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord3.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				float Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
			ZTest Always
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord6 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord3;
				texCoord11.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord5;
				texCoord76.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord4.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord4.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord4.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord4.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord4.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float IntenCustom69 = texCoord11.z;
				
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( IN.ase_color * temp_output_60_0 * (( _IntenCustomCustomZ )?( IntenCustom69 ):( _inten )) ).rgb;
				float Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord3 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord1;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord2;
				
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
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord;
				texCoord11.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord2;
				texCoord76.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord1.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord1.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord1.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				surfaceDescription.Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord3 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord1;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord2;
				
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
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord;
				texCoord11.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord2;
				texCoord76.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord1.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord1.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord1.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				surfaceDescription.Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord2;
				
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord1;
				texCoord11.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord3;
				texCoord76.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord2.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord2.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord2.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord2.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				surfaceDescription.Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DissolveTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTexTilingOffset;
			float4 _UVDistortPanZtime;
			float4 _UVDistortTileOffset;
			float4 _MaskPan;
			float2 _MainTexPanDirecCustomX;
			float _IntenCustomCustomZ;
			float _MaskStr;
			float _MaskStrCustomW;
			float _MaskPanCustom2zw;
			float _DissolveStr;
			float _Mask;
			float _inten;
			float _MainTex_inten;
			float _DistortionStr;
			float _UVDistortion;
			float _MainTexTIlingCustom2XY;
			float _dissolve;
			float _DissolveStrCustomCustomY;
			float _depth;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _UVDistotionTex;
			sampler2D _DissolveTex;
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
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord2;
				
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;

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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
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
				float4 texCoord11 = IN.ase_texcoord1;
				texCoord11.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult36 = (float2(_MainTexTilingOffset.x , _MainTexTilingOffset.y));
				float4 texCoord76 = IN.ase_texcoord3;
				texCoord76.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult118 = (float2(texCoord76.x , texCoord76.y));
				float2 MainTexTIlingCustomg74 = appendResult118;
				float2 appendResult37 = (float2(_MainTexTilingOffset.z , _MainTexTilingOffset.w));
				float mulTime83 = _TimeParameters.x * _UVDistortPanZtime.z;
				float2 appendResult81 = (float2(_UVDistortPanZtime.x , _UVDistortPanZtime.y));
				float2 appendResult85 = (float2(_UVDistortTileOffset.x , _UVDistortTileOffset.y));
				float2 appendResult86 = (float2(_UVDistortTileOffset.z , _UVDistortTileOffset.w));
				float2 texCoord77 = IN.ase_texcoord2.xy * appendResult85 + appendResult86;
				float2 panner78 = ( mulTime83 * appendResult81 + texCoord77);
				float2 texCoord5 = IN.ase_texcoord2.xy * (( _MainTexTIlingCustom2XY )?( MainTexTIlingCustomg74 ):( appendResult36 )) + (( _UVDistortion )?( ( appendResult37 + ( tex2D( _UVDistotionTex, panner78 ).r * _DistortionStr ) ) ):( appendResult37 ));
				float2 panner10 = ( texCoord11.x * _MainTexPanDirecCustomX + texCoord5);
				float temp_output_143_0 = ( tex2D( _MainTex, panner10 ).r * _MainTex_inten );
				float2 uv_DissolveTex = IN.ase_texcoord2.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float DissolveStrCustom31 = texCoord11.y;
				float2 appendResult89 = (float2(_MaskPan.x , _MaskPan.y));
				float2 appendResult93 = (float2(_MaskPan.z , _MaskPan.w));
				float MaskPanCustom90 = texCoord11.w;
				float2 temp_cast_0 = (MaskPanCustom90).xx;
				float2 texCoord44 = IN.ase_texcoord2.xy * appendResult89 + (( _MaskPanCustom2zw )?( temp_cast_0 ):( appendResult93 ));
				float temp_output_131_0 = texCoord44.x;
				float2 uv_MaskTex = IN.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_60_0 = saturate( (( _Mask )?( ( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) * ( ( (0.0 + (( temp_output_131_0 * ( 1.0 - temp_output_131_0 ) ) - 0.0) * (4.17 - 0.0) / (1.0 - 0.0)) + (( _MaskStrCustomW )?( MaskPanCustom90 ):( _MaskStr )) ) - tex2D( _MaskTex, uv_MaskTex ).r ) ) ):( (( _dissolve )?( saturate( ( temp_output_143_0 - ( tex2D( _DissolveTex, uv_DissolveTex ).r * (( _DissolveStrCustomCustomY )?( DissolveStrCustom31 ):( _DissolveStr )) ) ) ) ):( temp_output_143_0 )) )) );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth139 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth139 = saturate( abs( ( screenDepth139 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _depth ) ) );
				
				surfaceDescription.Alpha = ( ( IN.ase_color.a * temp_output_60_0 ) * distanceDepth139 );
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
190.4;185.6;1463.2;647;2499.638;865.319;1;True;False
Node;AmplifyShaderEditor.Vector4Node;84;-4162.794,-301.2558;Inherit;False;Property;_UVDistortTileOffset;UVDistortTileOffset;14;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;80;-3946.236,-90.35428;Inherit;False;Property;_UVDistortPanZtime;UVDistortPan(Ztime);15;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;86;-3937.794,-201.2558;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;85;-3935.794,-318.2558;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-3789.629,-236.2524;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;-0.19,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;81;-3737.097,-97.21132;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;83;-3622.794,0.3442383;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;78;-3552.32,-171.1103;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2210.505,331.5497;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-2145.896,157.5135;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-2976.21,-100.9594;Inherit;False;Property;_DistortionStr;DistortionStr;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;35;-3439.226,-536.0026;Inherit;False;Property;_MainTexTilingOffset;MainTexTilingOffset;2;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-3282.089,-227.8094;Inherit;True;Property;_UVDistotionTex;UVDistotionTex;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;118;-1983.375,344.837;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-1803.616,292.1068;Inherit;False;MaskPanCustom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-2922.195,-346.1593;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;88;-3346.129,476.491;Inherit;False;Property;_MaskPan;MaskPan;20;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-1823.333,363.6068;Inherit;False;MainTexTIlingCustomg;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2898.909,-202.7594;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-3030.97,606.3186;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2967.713,-559.1698;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-2767.544,-223.5941;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-3087.863,-456.177;Inherit;False;74;MainTexTIlingCustomg;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-3175.555,813.3216;Inherit;False;90;MaskPanCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-2879.649,516.6246;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;122;-2867.555,684.3216;Inherit;False;Property;_MaskPanCustom2zw;MaskPan(Custom2zw);22;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;72;-2784.235,-479.041;Inherit;False;Property;_MainTexTIlingCustom2XY;MainTexTIling(Custom2XY));3;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;18;-2640.097,-313.8749;Inherit;False;Property;_UVDistortion;UVDistortion;12;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;12;-2143.965,26.54602;Inherit;False;Property;_MainTexPanDirecCustomX;MainTexPanDirec(CustomX);4;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-2404.32,-384.2255;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1828.387,149.424;Inherit;False;DissolveStrCustom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;44;-2638.468,516.8901;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-1858.043,-403.1844;Inherit;False;Property;_DissolveStr;DissolveStr;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;10;-1789.447,-9.816425;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1917.477,-537.5578;Inherit;False;0;17;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;131;-2388.943,537.2811;Inherit;False;True;False;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1900.798,-320.82;Inherit;False;31;DissolveStrCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1430.4,115.3723;Inherit;False;Property;_MainTex_inten;MainTex_inten;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-1679.867,-596.8445;Inherit;True;Property;_DissolveTex;DissolveTex;8;0;Create;True;0;0;0;False;0;False;17;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;29;-1647.661,-384.8368;Inherit;False;Property;_DissolveStrCustomCustomY;DissolveStrCustom(CustomY);11;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;133;-2364.943,624.2811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-1598.171,-84.57067;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;None;0f1752693dac54c40aada52589cdf00f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-2140.943,549.2811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-2323.089,964.1006;Inherit;False;90;MaskPanCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2345.58,814.3217;Inherit;False;Property;_MaskStr;MaskStr;18;0;Create;True;0;0;0;False;0;False;13.75;13.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1372.452,-596.4434;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;-1298.4,-59.62772;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-2141.943,731.2811;Inherit;False;Constant;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;4.17;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;137;-1994.605,554.1679;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-1208.562,-377.7253;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;94;-2044.529,865.795;Inherit;False;Property;_MaskStrCustomW;MaskStr(CustomW);21;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-1729.208,543.6856;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-995.6875,-377.2521;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-1892.895,1056.503;Inherit;True;Property;_MaskTex;MaskTex;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;-1400.442,614.8819;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;14;-1091.781,-87.652;Inherit;True;Property;_dissolve;dissolve;7;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-801.8506,238.5951;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-580.8956,-15.18093;Inherit;True;Property;_Mask;Mask;17;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-257.4502,213.9798;Inherit;False;Property;_depth;depth;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;7;-202.4318,-202.0469;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;60;-274.5454,-7.312996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;139;-36.48526,159.8336;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;36.93717,7.221342;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;34;-2388.142,-624.3984;Inherit;False;Property;_DissolveTexTilingOffset;DissolveTexTilingOffset;9;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;71;-118.1271,-340.805;Inherit;False;Property;_IntenCustomCustomZ;IntenCustom(CustomZ);6;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;112;-2590.412,776.2615;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-1793.867,439.9214;Inherit;False;MaskOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;142.3706,-155.6128;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;-1982.419,432.2445;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-2111.142,-470.3984;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-368.9006,-323.3347;Inherit;False;69;IntenCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;303.5498,46.9798;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-2130.142,-580.3984;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-328.253,-409.6877;Inherit;False;Property;_inten;inten;5;0;Create;True;0;0;0;False;0;False;1;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1815.466,218.9107;Inherit;False;IntenCustom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;580.5328,-75.93917;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;Default;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;637933050437724935;  Blend;0;638005469063106372;Two Sided;0;637933050459729924;Cast Shadows;0;637933050481640916;  Use Shadow Threshold;0;0;Receive Shadows;0;637980299704285454;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;67;518.9669,-23.61592;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;518.9669,-23.61592;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;65;518.9669,-23.61592;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;64;518.9669,-23.61592;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;518.9669,-23.61592;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;86;0;84;3
WireConnection;86;1;84;4
WireConnection;85;0;84;1
WireConnection;85;1;84;2
WireConnection;77;0;85;0
WireConnection;77;1;86;0
WireConnection;81;0;80;1
WireConnection;81;1;80;2
WireConnection;83;0;80;3
WireConnection;78;0;77;0
WireConnection;78;2;81;0
WireConnection;78;1;83;0
WireConnection;22;1;78;0
WireConnection;118;0;76;1
WireConnection;118;1;76;2
WireConnection;90;0;11;4
WireConnection;37;0;35;3
WireConnection;37;1;35;4
WireConnection;74;0;118;0
WireConnection;61;0;22;1
WireConnection;61;1;62;0
WireConnection;93;0;88;3
WireConnection;93;1;88;4
WireConnection;36;0;35;1
WireConnection;36;1;35;2
WireConnection;63;0;37;0
WireConnection;63;1;61;0
WireConnection;89;0;88;1
WireConnection;89;1;88;2
WireConnection;122;0;93;0
WireConnection;122;1;124;0
WireConnection;72;0;36;0
WireConnection;72;1;75;0
WireConnection;18;0;37;0
WireConnection;18;1;63;0
WireConnection;5;0;72;0
WireConnection;5;1;18;0
WireConnection;31;0;11;2
WireConnection;44;0;89;0
WireConnection;44;1;122;0
WireConnection;10;0;5;0
WireConnection;10;2;12;0
WireConnection;10;1;11;1
WireConnection;24;0;32;0
WireConnection;24;1;33;0
WireConnection;131;0;44;1
WireConnection;17;1;24;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;133;0;131;0
WireConnection;6;1;10;0
WireConnection;134;0;131;0
WireConnection;134;1;133;0
WireConnection;27;0;17;1
WireConnection;27;1;29;0
WireConnection;143;0;6;1
WireConnection;143;1;145;0
WireConnection;137;0;134;0
WireConnection;137;4;138;0
WireConnection;16;0;143;0
WireConnection;16;1;27;0
WireConnection;94;0;50;0
WireConnection;94;1;91;0
WireConnection;116;0;137;0
WireConnection;116;1;94;0
WireConnection;23;0;16;0
WireConnection;126;0;116;0
WireConnection;126;1;45;1
WireConnection;14;0;143;0
WireConnection;14;1;23;0
WireConnection;117;0;14;0
WireConnection;117;1;126;0
WireConnection;40;0;14;0
WireConnection;40;1;117;0
WireConnection;60;0;40;0
WireConnection;139;0;142;0
WireConnection;9;0;7;4
WireConnection;9;1;60;0
WireConnection;71;0;13;0
WireConnection;71;1;70;0
WireConnection;119;0;121;0
WireConnection;8;0;7;0
WireConnection;8;1;60;0
WireConnection;8;2;71;0
WireConnection;121;0;76;3
WireConnection;121;1;76;4
WireConnection;33;0;34;3
WireConnection;33;1;34;4
WireConnection;140;0;9;0
WireConnection;140;1;139;0
WireConnection;32;0;34;1
WireConnection;32;1;34;2
WireConnection;69;0;11;3
WireConnection;1;2;8;0
WireConnection;1;3;140;0
ASEEND*/
//CHKSM=71A35AE613E7F2F370387CD60FB1F1421E1B5BEE