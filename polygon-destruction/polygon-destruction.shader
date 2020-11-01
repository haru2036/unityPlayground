Shader "Custom/Polygon Destruction (Random)"
{
	Properties
	{
		_WeightMap ("WeightMap", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
		[HDR] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
		_ScaleFactor ("Scale Factor", float) = 0.5
		_Speed ("Speed", float) = 0.5
	}
	SubShader
	{
		Blend SrcAlpha OneMinusSrcAlpha
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag 

			#include "UnityCG.cginc"

			sampler2D _WeightMap;
			fixed4 _Color;
			fixed _ScaleFactor;
			fixed _Speed;
			float4 _EmissionColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float3 barycentricCoords : TEXCOORD1;
				float distance : TEXCOORD2;
			};

			float rand(float2 seed)
			{
				return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
			}
			
			appdata vert (appdata v)
			{
				return v;
			}

			[maxvertexcount(3)]
			void geom (triangle appdata input[3], uint primitiveId : SV_PrimitiveID, inout TriangleStream<g2f> stream)
			{
				float3 vec1 = input[1].vertex - input[0].vertex;
				float3 vec2 = input[2].vertex - input[0].vertex;
				float3 normal = normalize(cross(vec1, vec2));

				fixed random = rand(primitiveId);
				fixed destruction = clamp(((sin(_Time * 4 * primitiveId * _Speed) * 0.5) + 0.5), 0.01, 1.0);
				float4 tex2DlodArgs = float4(input[0].uv.x, input[0].uv.y, 0, 0);
				fixed weight = tex2Dlod(_WeightMap, tex2DlodArgs);

				[unroll]
				for(int i = 0; i < 3; i++)
				{
					appdata v = input[i];
					g2f o;
					v.vertex.xyz += normal * destruction * _ScaleFactor * random * weight; 
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;

					o.color = fixed4(_Color.rgb, 1.0);
					float3 barycentricCoords = fixed3(0.0, 0.0, 0.0);
					barycentricCoords[i] = 1.0;
					o.barycentricCoords = barycentricCoords;

					o.distance = destruction;
					stream.Append(o);
				}
				stream.RestartStrip();
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				float3 barys;
				barys.xy = i.barycentricCoords;
				barys.z = 1 - barys.x - barys.y;
				float deltas = fwidth(barys);
				float3 smoothing = deltas * 0.5;
				float3 thickness = deltas;

				barys = smoothstep(thickness, thickness + smoothing, barys);
				float minBary = min(barys.x, min(barys.y, barys.z));
				fixed4 col = tex2D(_WeightMap, i.uv);
				fixed4 r = col * i.color + _EmissionColor;
				r.a = col.x;
				return r * (1 - (minBary * (1 - i.distance)));
			}
			ENDCG
		}
	}
	FallBack "Unlit/Color"
}