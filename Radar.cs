using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
public class Radar : MonoBehaviour
{
    public Material RadarMaterial;
    public Transform[] DetectableObjects;
    public Vector4[] Points;
    public float DividerCoefficient = 1000;
    private void Start()
    {
        Points = new Vector4[DetectableObjects.Length];
    }

    private void Update()
    {
        //Objects are displayed but scaling is a little rough, a little work needed for it.
        for(var i = 0; i < DetectableObjects.Length; i++)
        {
            Points[i] = new Vector2(DetectableObjects[i].position.x, DetectableObjects[i].position.z);
            Points[i] /= DividerCoefficient;
        }
        RadarMaterial.SetVectorArray("_Points", Points.ToArray());
        RadarMaterial.SetInt("_PointCount", Points.Length);
    }

}
