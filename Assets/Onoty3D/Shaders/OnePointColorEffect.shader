﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//http://onoty3d.hatenablog.com/entry/2016/02/06/141002
//http://onoty3d.hatenablog.com/entry/2016/05/15/205451

Shader "Onoty3D/OnePointColorEffect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_TargetColor("Target Color", Color) = (1,0,0)
		_Near("Near", Range(0, 0.5)) = 0.1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed GetHue(fixed3 rgb) {
				fixed hue = 0;
				fixed minValue = min(rgb.r, min(rgb.g, rgb.b));
				fixed maxValue = max(rgb.r, max(rgb.g, rgb.b));
				fixed delta = maxValue - minValue;
				if (delta != 0) {
					if (maxValue == rgb.r) {
						hue = (rgb.g - rgb.b) / delta;
					}
					else if (maxValue == rgb.g) {
						hue = 2.0 + (rgb.b - rgb.r) / delta;
					}
					else {
						hue = 4.0 + (rgb.r - rgb.g) / delta;
					}

					hue /= 6.0;

					if (hue < 0) {
						hue += 1.0;
					}
				}
				return hue;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			fixed3 _TargetColor;
			fixed _Near;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed distance = GetHue(col.rgb) - GetHue(_TargetColor);
                
				if (distance > 0.5) {
					distance = 1.0 - distance;
				}
				else if (distance < -0.5) {
					distance = 1.0 + distance;
				}
				else {
					distance = abs(distance);
				}



                if (distance < _Near) {
                    //col.r = 255;
                    //col.g = 71;
                    //col.b = 158;


                //念のため，elseの後もif入れておく
                } else if (distance > _Near) {
                    /*
                    fixed gray = ((col.r + col.g + col.b) / 3.0);
					col.r = gray;
					col.g = gray;
					col.b = gray;
                    */


                    //Nearより遠い色はとりあえず念のため白w
                    /*col.r = 255;
                    col.g = 255;
                    col.b = 255;*/

                    //Nearより遠い色は透明にw
                    col.a = 0.0;

				}

				return col;
			}
			ENDCG
		}
	}
}
