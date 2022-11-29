// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/UI"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_inten("inten", Float) = 1
		_MainStr("MainStr", Float) = 1
		_Main_Tex("Main_Tex", 2D) = "white" {}
		[Toggle]_Polar("Polar", Float) = 0
		[Toggle]_Main_Panning("Main_Panning", Float) = 0
		_PanCtrl("PanCtrl", Vector) = (0,0,0,0)
		[Toggle]_PanTimeCustomX("PanTimeCustom(X)", Float) = 0
		[Toggle]_Dissolve("Dissolve", Float) = 1
		_DissolveStr("DissolveStr", Range( -2 , 1)) = -1
		[Toggle]_DissovleStrCustomY("DissovleStrCustom(Y)", Float) = 0
		_Dissolve_Tex("Dissolve_Tex", 2D) = "white" {}
		[Toggle]_DissolvePolar("DissolvePolar", Float) = 1
		_PolarLengthh("PolarLengthh", Float) = 1
		[Toggle]_Dissolve_Panning("Dissolve_Panning", Float) = 1
		_DissolvePanCtrl("DissolvePanCtrl", Vector) = (0,0,0,0)
		[Toggle]_DissolveMaskVer("DissolveMaskVer", Float) = 0
		[Toggle]_DissolveMaskDirection("DissolveMaskDirection", Float) = 0
		_DissolveMaskCtrlZ("DissolveMaskCtrl(Z)", Vector) = (0,0,0,0)
		_DissolveMaskPow("DissolveMaskPow", Float) = 6.21
		[Toggle]_Distortion("Distortion", Float) = 1
		_DistortionStr("DistortionStr", Float) = 0
		_Distortion_Tex("Distortion_Tex", 2D) = "white" {}
		[Toggle]_DistortionPolar("DistortionPolar", Float) = 1
		_PolarLength("PolarLength", Float) = 1
		[Toggle]_Distortion_Panning("Distortion_Panning", Float) = 1
		_DistortionPanCtrl("DistortionPanCtrl", Vector) = (0,0,0,0)
		[Toggle]_MaskDirectionY("MaskDirectionY", Float) = 0
		[Toggle]_MaskDirectionX("MaskDirectionX", Float) = 0
		[Toggle]_MaskTexture("MaskTexture", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		_MaskTexStr("MaskTexStr", Range( 0 , 10)) = 1
		[Toggle]_Toon("Toon", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_COLOR

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform float _inten;
			uniform float _Toon;
			uniform float _MaskTexture;
			uniform float _MaskDirectionX;
			uniform float _MaskDirectionY;
			uniform float _Dissolve;
			uniform sampler2D _Main_Tex;
			uniform float _Main_Panning;
			uniform float _Distortion;
			uniform float _Polar;
			uniform float _DistortionStr;
			uniform sampler2D _Distortion_Tex;
			uniform float _Distortion_Panning;
			uniform float _DistortionPolar;
			uniform float _PolarLength;
			uniform float4 _DistortionPanCtrl;
			uniform float _PanTimeCustomX;
			uniform float4 _PanCtrl;
			uniform float _MainStr;
			uniform float _DissolveMaskVer;
			uniform sampler2D _Dissolve_Tex;
			uniform float _Dissolve_Panning;
			uniform float _DissolvePolar;
			uniform float _PolarLengthh;
			uniform float4 _DissolvePanCtrl;
			uniform float _DissovleStrCustomY;
			uniform float _DissolveStr;
			uniform float _DissolveMaskDirection;
			uniform float4 _DissolveMaskCtrlZ;
			uniform float _DissolveMaskPow;
			uniform sampler2D _MaskTex;
			uniform float4 _MaskTex_ST;
			uniform float _MaskTexStr;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float3 appendResult124 = (float3(IN.color.r , IN.color.g , IN.color.b));
				float2 texCoord19 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g7 = ( texCoord19 - float2( 0.5,0.5 ) );
				float2 break17_g7 = CenteredUV15_g7;
				float2 appendResult23_g7 = (float2(( length( CenteredUV15_g7 ) * 1.0 * 2.0 ) , ( atan2( break17_g7.x , break17_g7.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float2 texCoord5 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g1 = ( texCoord5 - float2( 0.5,0.5 ) );
				float2 break17_g1 = CenteredUV15_g1;
				float2 appendResult23_g1 = (float2(( length( CenteredUV15_g1 ) * 1.0 * 2.0 ) , ( atan2( break17_g1.x , break17_g1.y ) * ( 1.0 / 6.28318548202515 ) * _PolarLength )));
				float mulTime6 = _Time.y * _DistortionPanCtrl.z;
				float2 appendResult10 = (float2(_DistortionPanCtrl.x , _DistortionPanCtrl.y));
				float2 panner12 = ( ( mulTime6 + _DistortionPanCtrl.w ) * appendResult10 + (( _DistortionPolar )?( appendResult23_g1 ):( texCoord5 )));
				float mulTime37 = _Time.y * _PanCtrl.z;
				float4 texCoord14 = IN.worldPosition.xyzw;
				texCoord14.xy = IN.worldPosition.xyzw.xy * float2( 1,1 ) + float2( 0,0 );
				float PanTimeCtrl32 = texCoord14.x;
				float2 appendResult49 = (float2(_PanCtrl.x , _PanCtrl.y));
				float2 panner57 = ( (( _PanTimeCustomX )?( PanTimeCtrl32 ):( ( mulTime37 + _PanCtrl.w ) )) * appendResult49 + (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner12 ):( (( _DistortionPolar )?( appendResult23_g1 ):( texCoord5 )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( texCoord19 )) ) ):( (( _Polar )?( appendResult23_g7 ):( texCoord19 )) )));
				float temp_output_67_0 = ( tex2D( _Main_Tex, (( _Main_Panning )?( panner57 ):( (( _Distortion )?( ( ( _DistortionStr * tex2D( _Distortion_Tex, (( _Distortion_Panning )?( panner12 ):( (( _DistortionPolar )?( appendResult23_g1 ):( texCoord5 )) )) ).r ) + (( _Polar )?( appendResult23_g7 ):( texCoord19 )) ) ):( (( _Polar )?( appendResult23_g7 ):( texCoord19 )) )) )) ).r * _MainStr );
				float2 texCoord16 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 CenteredUV15_g8 = ( texCoord16 - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / 6.28318548202515 ) * _PolarLengthh )));
				float mulTime24 = _Time.y * _DissolvePanCtrl.z;
				float2 appendResult30 = (float2(_DissolvePanCtrl.x , _DissolvePanCtrl.y));
				float2 panner45 = ( ( mulTime24 + _DissolvePanCtrl.w ) * appendResult30 + (( _DissolvePolar )?( appendResult23_g8 ):( texCoord16 )));
				float4 tex2DNode54 = tex2D( _Dissolve_Tex, (( _Dissolve_Panning )?( panner45 ):( (( _DissolvePolar )?( appendResult23_g8 ):( texCoord16 )) )) );
				float DissolveStrCustom41 = texCoord14.y;
				float mulTime26 = _Time.y * _DissolveMaskCtrlZ.z;
				float DissolveMaskStr21 = texCoord14.z;
				float2 appendResult33 = (float2(_DissolveMaskCtrlZ.x , _DissolveMaskCtrlZ.y));
				float2 texCoord34 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner40 = ( ( mulTime26 + DissolveMaskStr21 ) * appendResult33 + texCoord34);
				float2 break50 = panner40;
				float lerpResult60 = lerp( tex2DNode54.r , (( _DissolveMaskDirection )?( break50.y ):( break50.x )) , _DissolveMaskPow);
				float temp_output_65_0 = ( 1.0 - lerpResult60 );
				float temp_output_95_0 = (0.0 + (( IN.texcoord.xy.x * ( 1.0 - IN.texcoord.xy.x ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0));
				float2 uv_MaskTex = IN.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float3 break125 = ( appendResult124 * _inten * (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_95_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_95_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) )) )) )) );
				float4 appendResult123 = (float4(break125.x , break125.y , break125.z , ( (( _Toon )?( ( 1.0 - step( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_95_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) )) )) , 0.7 ) ) ):( (( _MaskTexture )?( (0.0 + (( ( tex2D( _MaskTex, uv_MaskTex ).r * _MaskTexStr ) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) - 0.0) * ((( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) - 0.0) / (1.0 - 0.0)) ):( (( _MaskDirectionX )?( ( temp_output_95_0 * (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) ) ):( (( _MaskDirectionY )?( ( (0.0 + (( IN.texcoord.xy.y * ( 1.0 - IN.texcoord.xy.y ) ) - 0.0) * (4.0 - 0.0) / (1.0 - 0.0)) * (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) ) ):( (( _Dissolve )?( saturate( (0.0 + (( temp_output_67_0 - (( _DissolveMaskVer )?( temp_output_65_0 ):( ( tex2DNode54.r * (0.0 + ((( _DissovleStrCustomY )?( DissolveStrCustom41 ):( _DissolveStr )) - -1.0) * (50.0 - 0.0) / (1.0 - -1.0)) ) )) ) - 0.0) * (temp_output_67_0 - 0.0) / (1.0 - 0.0)) ) ):( temp_output_67_0 )) )) )) )) )) * IN.color.a )));
				
				half4 color = appendResult123;
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
225.6;331.2;1463.2;647;5874.27;1440.474;4.952312;True;False
Node;AmplifyShaderEditor.CommentaryNode;2;-6140.98,-592.576;Inherit;False;1450.268;460.3232;UVDistortion;12;28;25;20;12;10;9;8;7;6;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;3;-6076.246,-310.1195;Inherit;False;Property;_DistortionPanCtrl;DistortionPanCtrl;25;0;Create;True;0;0;0;False;0;False;0,0,0,0;-0.2,0,0.5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-5996.145,-400.5256;Inherit;False;Property;_PolarLength;PolarLength;23;0;Create;True;0;0;0;False;0;False;1;3.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-6094.929,-563.8376;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;6;-5834.334,-262.4046;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-5826.338,-489.1215;Inherit;False;Polar Coordinates;-1;;1;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-5595.227,-233.6944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;9;-5591.924,-547.0625;Inherit;False;Property;_DistortionPolar;DistortionPolar;22;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-5668.153,-349.1665;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;11;-4429.019,-892.3921;Inherit;False;589.4069;433.9417;Custom;5;113;41;32;21;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;12;-5476.17,-331.4653;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;13;-4805.105,527.8726;Inherit;False;1370.011;487.8423;Dissolve;15;59;54;53;52;48;47;45;36;31;30;29;24;18;16;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-4379.019,-770.5264;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;15;-4755.105,806.7148;Inherit;False;Property;_DissolvePanCtrl;DissolvePanCtrl;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;-0.2,0,0.5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-4777.686,569.1845;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;17;-4428.207,1215.834;Inherit;False;Property;_DissolveMaskCtrlZ;DissolveMaskCtrl(Z);17;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-4738.744,717.5679;Inherit;False;Property;_PolarLengthh;PolarLengthh;12;0;Create;True;0;0;0;False;0;False;1;4.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-5004.788,-98.89915;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;20;-5283.726,-428.5903;Inherit;False;Property;_Distortion_Panning;Distortion_Panning;24;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-4077.365,-667.8404;Inherit;False;DissolveMaskStr;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;22;-4501.018,189.9865;Inherit;False;Property;_PanCtrl;PanCtrl;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;23;-4223.39,1366.079;Inherit;False;21;DissolveMaskStr;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-4426.299,877.7959;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-5012.311,-410.8631;Inherit;True;Property;_Distortion_Tex;Distortion_Tex;21;0;Create;True;0;0;0;False;0;False;-1;None;ac63406a92dd52842a290ab5c49b362d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;26;-4204.917,1292.451;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;27;-4772.405,-26.05466;Inherit;False;Polar Coordinates;-1;;7;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-4934.714,-576.0967;Inherit;False;Property;_DistortionStr;DistortionStr;20;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;29;-4544.07,639.878;Inherit;False;Polar Coordinates;-1;;8;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-4251.564,1076.726;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;30;-4349,771.2818;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-4247.667,904.0309;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;-4193.207,1196.24;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-4070.174,-842.3921;Inherit;False;PanTimeCtrl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;37;-4277.322,291.0817;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;36;-4293.203,567.5828;Inherit;False;Property;_DissolvePolar;DissolvePolar;11;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-4559.592,-366.6813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-4028.31,1286.511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;35;-4550.991,-101.9957;Inherit;False;Property;_Polar;Polar;3;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;40;-3962.713,1164.186;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-4090.812,-757.3759;Inherit;False;DissolveStrCustom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-4284.734,413.606;Inherit;False;32;PanTimeCtrl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-4114.311,296.8398;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-4159.169,-277.5374;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;45;-4157.017,788.9832;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-4112.621,928.2699;Inherit;False;41;DissolveStrCustom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;46;-3978.84,318.4385;Inherit;False;Property;_PanTimeCustomX;PanTimeCustom(X);6;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;47;-3977.059,593.0686;Inherit;False;Property;_Dissolve_Panning;Dissolve_Panning;13;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-4082.998,198.0435;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;51;-4110.961,-59.79842;Inherit;False;Property;_Distortion;Distortion;19;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-3918.564,817.5678;Inherit;False;Property;_DissolveStr;DissolveStr;8;0;Create;True;0;0;0;False;0;False;-1;-1.86;-2;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;50;-3782.852,1077.717;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ToggleSwitchNode;53;-3878.174,898.0299;Inherit;False;Property;_DissovleStrCustomY;DissovleStrCustom(Y);9;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-3756.694,578.7443;Inherit;True;Property;_Dissolve_Tex;Dissolve_Tex;10;0;Create;True;0;0;0;False;0;False;-1;None;a23372ee982ab3841a3b6294eeb707ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-3280.658,1097.401;Inherit;False;Property;_DissolveMaskPow;DissolveMaskPow;18;0;Create;True;0;0;0;False;0;False;6.21;6.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;56;-3604.667,1075.538;Inherit;True;Property;_DissolveMaskDirection;DissolveMaskDirection;16;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;57;-3777.015,190.7449;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;58;-3826.387,-1256.572;Inherit;False;1488.185;789.6182;Mask;21;117;100;98;95;94;93;92;91;90;88;87;85;84;81;78;76;73;71;70;68;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;59;-3606.888,785.8724;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-3094.64,823.2899;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;61;-3778.573,-12.61576;Inherit;False;Property;_Main_Panning;Main_Panning;4;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;62;-3772.703,-754.3359;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3337.3,598.4295;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;65;-2861.825,826.0969;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-3489.946,3.436235;Inherit;True;Property;_Main_Tex;Main_Tex;2;0;Create;True;0;0;0;False;0;False;-1;None;e8604acf4de2601468d65fd2ecd140a2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-3375.093,211.5175;Inherit;False;Property;_MainStr;MainStr;1;0;Create;True;0;0;0;False;0;False;1;0.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3147.002,31.75504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;68;-3534.572,-594.4392;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;69;-3200.41,691.5504;Inherit;True;Property;_DissolveMaskVer;DissolveMaskVer;15;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-3327.377,-603.421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;71;-3533.364,-680.5254;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-3040.862,475.1852;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-3190.332,-679.3094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;74;-2791.369,439.3958;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;75;-2559.45,380.4574;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;76;-3033.004,-709.4205;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;78;-2567.888,-499.5068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;77;-2807.47,46.66124;Inherit;False;Property;_Dissolve;Dissolve;7;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2398.7,-361.5711;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;80;-2175.884,-409.3573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;81;-3531.571,-853.8184;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;82;-2303.884,-462.1573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;83;-2644.839,-393.8463;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;-3292.283,-888.4758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;85;-3519.665,-954.7;Inherit;False;True;True;True;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;86;-2279.477,-598.3569;Inherit;False;Property;_MaskDirectionY;MaskDirectionY;26;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;91;-2693.213,-959.3362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3297.052,-1070.421;Inherit;False;Property;_MaskTexStr;MaskTexStr;30;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;89;-2069.243,-626.3412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-3183.448,-931.3561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;88;-3585.721,-1187.823;Inherit;True;Property;_MaskTex;MaskTex;29;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-3178.052,-1174.421;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;92;-3059.13,-1062.724;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;95;-3023.71,-953.1132;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;94;-2475.016,-687.2353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;96;-2752.184,-217.0226;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2182.824,-842.743;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-2980.369,-1176.515;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;99;-1920.602,-711.9753;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;100;-2625.755,-1158.609;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;101;-2045.008,-369.2231;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;103;-1676.892,-897.557;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;102;-1872.438,-247.095;Inherit;False;Property;_MaskDirectionX;MaskDirectionX;27;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1354.051,-276.7892;Inherit;False;Constant;_ToonStr;ToonStr;26;0;Create;True;0;0;0;False;0;False;0.7;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;104;-1602.086,-249.7728;Inherit;True;Property;_MaskTexture;MaskTexture;28;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;106;-1200.822,-453.0559;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;107;-974.4872,-445.9869;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;112;-523.8964,-263.4773;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;108;-747.7383,-149.2908;Inherit;False;Property;_Toon;Toon;31;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;124;-329.4626,-243.498;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-323.7254,-323.5816;Inherit;False;Property;_inten;inten;0;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;-498.6103,12.35623;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-144.5801,-263.0321;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;111;-561.0654,23.37744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-140.4285,59.33554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;125;5.996093,-120.4706;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;123;144.5197,-101.3589;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-4083.578,-573.8503;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-2716.11,773.1583;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-2742.551,-853.6838;Inherit;False;MaskTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;116;-5442.322,-90.22732;Inherit;False;Constant;_Vector0;Vector 0;23;0;Create;True;0;0;0;False;0;False;1,2,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;118;-5229.423,-3.684759;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;-5224.35,-98.04421;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;376,-86.00002;Float;False;True;-1;2;ASEMaterialInspector;0;6;Custom/UI;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;6;0;3;3
WireConnection;7;1;5;0
WireConnection;7;4;4;0
WireConnection;8;0;6;0
WireConnection;8;1;3;4
WireConnection;9;0;5;0
WireConnection;9;1;7;0
WireConnection;10;0;3;1
WireConnection;10;1;3;2
WireConnection;12;0;9;0
WireConnection;12;2;10;0
WireConnection;12;1;8;0
WireConnection;20;0;9;0
WireConnection;20;1;12;0
WireConnection;21;0;14;3
WireConnection;24;0;15;3
WireConnection;25;1;20;0
WireConnection;26;0;17;3
WireConnection;27;1;19;0
WireConnection;29;1;16;0
WireConnection;29;4;18;0
WireConnection;30;0;15;1
WireConnection;30;1;15;2
WireConnection;31;0;24;0
WireConnection;31;1;15;4
WireConnection;33;0;17;1
WireConnection;33;1;17;2
WireConnection;32;0;14;1
WireConnection;37;0;22;3
WireConnection;36;0;16;0
WireConnection;36;1;29;0
WireConnection;38;0;28;0
WireConnection;38;1;25;1
WireConnection;39;0;26;0
WireConnection;39;1;23;0
WireConnection;35;0;19;0
WireConnection;35;1;27;0
WireConnection;40;0;34;0
WireConnection;40;2;33;0
WireConnection;40;1;39;0
WireConnection;41;0;14;2
WireConnection;43;0;37;0
WireConnection;43;1;22;4
WireConnection;44;0;38;0
WireConnection;44;1;35;0
WireConnection;45;0;36;0
WireConnection;45;2;30;0
WireConnection;45;1;31;0
WireConnection;46;0;43;0
WireConnection;46;1;42;0
WireConnection;47;0;36;0
WireConnection;47;1;45;0
WireConnection;49;0;22;1
WireConnection;49;1;22;2
WireConnection;51;0;35;0
WireConnection;51;1;44;0
WireConnection;50;0;40;0
WireConnection;53;0;52;0
WireConnection;53;1;48;0
WireConnection;54;1;47;0
WireConnection;56;0;50;0
WireConnection;56;1;50;1
WireConnection;57;0;51;0
WireConnection;57;2;49;0
WireConnection;57;1;46;0
WireConnection;59;0;53;0
WireConnection;60;0;54;1
WireConnection;60;1;56;0
WireConnection;60;2;55;0
WireConnection;61;0;51;0
WireConnection;61;1;57;0
WireConnection;64;0;54;1
WireConnection;64;1;59;0
WireConnection;65;0;60;0
WireConnection;63;1;61;0
WireConnection;67;0;63;1
WireConnection;67;1;66;0
WireConnection;68;0;62;2
WireConnection;69;0;64;0
WireConnection;69;1;65;0
WireConnection;70;0;68;0
WireConnection;71;0;62;2
WireConnection;72;0;67;0
WireConnection;72;1;69;0
WireConnection;73;0;71;0
WireConnection;73;1;70;0
WireConnection;74;0;72;0
WireConnection;74;4;67;0
WireConnection;75;0;74;0
WireConnection;76;0;73;0
WireConnection;78;0;76;0
WireConnection;77;0;67;0
WireConnection;77;1;75;0
WireConnection;79;0;78;0
WireConnection;79;1;77;0
WireConnection;80;0;79;0
WireConnection;81;0;62;1
WireConnection;82;0;80;0
WireConnection;83;0;77;0
WireConnection;84;0;81;0
WireConnection;85;0;62;1
WireConnection;86;0;83;0
WireConnection;86;1;82;0
WireConnection;91;0;77;0
WireConnection;89;0;86;0
WireConnection;90;0;85;0
WireConnection;90;1;84;0
WireConnection;93;0;88;1
WireConnection;93;1;87;0
WireConnection;92;0;91;0
WireConnection;95;0;90;0
WireConnection;94;0;89;0
WireConnection;96;0;77;0
WireConnection;97;0;95;0
WireConnection;97;1;94;0
WireConnection;98;0;93;0
WireConnection;98;1;92;0
WireConnection;99;0;97;0
WireConnection;100;0;98;0
WireConnection;100;4;96;0
WireConnection;101;0;86;0
WireConnection;103;0;100;0
WireConnection;102;0;101;0
WireConnection;102;1;99;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;106;0;104;0
WireConnection;106;1;105;0
WireConnection;107;0;106;0
WireConnection;108;0;104;0
WireConnection;108;1;107;0
WireConnection;124;0;112;1
WireConnection;124;1;112;2
WireConnection;124;2;112;3
WireConnection;120;0;108;0
WireConnection;119;0;124;0
WireConnection;119;1;122;0
WireConnection;119;2;120;0
WireConnection;111;0;108;0
WireConnection;114;0;111;0
WireConnection;114;1;112;4
WireConnection;125;0;119;0
WireConnection;123;0;125;0
WireConnection;123;1;125;1
WireConnection;123;2;125;2
WireConnection;123;3;114;0
WireConnection;115;0;65;0
WireConnection;117;0;95;0
WireConnection;118;0;116;3
WireConnection;118;1;116;4
WireConnection;121;0;116;1
WireConnection;121;1;116;2
WireConnection;1;0;123;0
ASEEND*/
//CHKSM=5FF16827BAC8DC3A39CED6059BD6BDAD40A03A6C