using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IRotate
{
    void CheckRotate(AxisRotateObject ax = null);
    void Rotate(Vector3 pos);
}
