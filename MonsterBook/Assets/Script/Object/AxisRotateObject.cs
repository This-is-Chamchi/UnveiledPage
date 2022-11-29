using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AxisRotateObject : MonoBehaviour
{
    [SerializeField] private bool autoAxis;
    [SerializeField] private bool rotateRight;
    private IRotate player;
    
    
    public bool SetRotate()
    {
        var val = rotateRight;
        rotateRight = !rotateRight;

        return val;
    }

    private void OnTriggerEnter(Collider other)
    {
        player = other.GetComponent<IRotate>();
        if (player != null)
        {
            player.CheckRotate(this);
            if (autoAxis)
            {
                player.Rotate(transform.position);
            }

        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (player != null) player.CheckRotate();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.grey;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }
}
