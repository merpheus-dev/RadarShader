Shader "Unlit/Radar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Speed("Speed",Float) = 5.0
		_Thickness("Thickness",Float) = 1
		//_PointCount("Point Count",Float)=100
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
			Blend One OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"

			#define PI  3.14159265359
			

			 struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Speed;
			float _Thickness;
			float4 _Points[100];
			float _PointCount;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float getModulo(float a, float b) {
				return a - (b * floor(a / b));
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;
				uv -= .5;
				float dist = length(uv);
				float speed = _Speed;
				float angle = (-_Time * speed)% ( 2. * PI);
				float clippedGreen = 0.;
				
				float containerRadius = .475;
				float clipToRadius = clamp(floor(containerRadius / dist), 0., 1.);
				float containerThickness = 0.01;
				float container = smoothstep(containerRadius + containerThickness / 2., containerRadius, dist)
						* smoothstep(containerRadius - containerThickness / 2., containerRadius, dist);
				float blipSpeed = .075;
				float ringThickness = .01*_Thickness;
				for (int x = 0; x < _PointCount; x++) {
					float blipDist = distance(uv, _Points[x]);
					float blipAngle = (atan2(_Points[x].y, _Points[x].x) + PI * 2.)%( PI * 2.) - PI / 3.;
					float angleDiff = (angle - blipAngle)%( 2. * PI);
					float blipRadius = (1. - angleDiff) * blipSpeed;
					float addend = smoothstep(blipRadius, blipRadius - ringThickness / 2., blipDist)
						* pow(smoothstep(0., blipRadius - ringThickness / 2., blipDist), 3.);
					clippedGreen += max(0., lerp(addend, 0., blipRadius / blipSpeed));
				}


				float gridIncrement = .1;
				float gridLineThickness = 1./_ScreenParams.y*_Thickness;
				float gridAddend = (1. - step(gridLineThickness, getModulo(uv.x, gridIncrement)))
					+ (1. - step(gridLineThickness, getModulo(uv.y, gridIncrement)));
				clippedGreen+= gridAddend;

				float gradientAngleAmount = PI / 4.;
				float uvAngle = (atan2(uv.y, uv.x) + PI * 2.)%( PI * 2.);
				float angleDiff = getModulo(uvAngle - angle, 2. * PI);
				clippedGreen += smoothstep(gradientAngleAmount, 0., angleDiff);

				uv.x /= _ScreenParams.x / _ScreenParams.y;
				uv += .5;
				float4 col = float4(0., 0., 0., 0.);
				col.r += container+clippedGreen*clipToRadius;
				return col;
            }
            ENDCG
        }
    }
}
