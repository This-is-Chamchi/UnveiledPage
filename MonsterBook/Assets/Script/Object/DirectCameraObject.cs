using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectCameraObject : MonoBehaviour
{
    [SerializeField] private Transform cameraPos;
    [SerializeField] private float speed = 4;


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player") || other.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            CameraController.StartDirectCamera(cameraPos.position, speed);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player") || other.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            CameraController.EndDirecCamera();
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.black;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }

}
