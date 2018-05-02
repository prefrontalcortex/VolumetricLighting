Shader "Hidden/ApplyToOpaque" {
SubShader {
Pass {
	ZTest Always Cull Off ZWrite Off
	Blend Off

CGPROGRAM
	#pragma target 3.5
	#include "UnityCG.cginc"
	#include "VolumetricFog.cginc"
	#pragma vertex vert
	#pragma fragment frag

	sampler2D _CameraDepthTexture;
	sampler2D _MainTex;
	float4 _MainTex_ST;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert (appdata_img v)
	{
		v2f o;
		o.pos = v.vertex;
		o.pos.xy = o.pos.xy * 2 - 1;
		o.uv = v.texcoord.xy;
		
		#if UNITY_UV_STARTS_AT_TOP
		if (_ProjectionParams.x < 0)
			o.uv.y = 1-o.uv.y;
		#endif
		
		return o;
	}
		
	half4 frag (v2f i) : SV_Target
	{
		float2 uv = UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST);
		half linear01Depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
		half4 fog = Fog(linear01Depth, uv);
		return tex2D(_MainTex, uv) * fog.a + fog;
	}

ENDCG
}
}
}
