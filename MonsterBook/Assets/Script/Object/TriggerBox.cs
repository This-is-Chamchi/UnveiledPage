using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TriggerBox : MonoBehaviour
{
    [SerializeField] private bool playOnece;
    [SerializeField] private UnityEvent enterTrigger;
    [SerializeField] private UnityEvent exitTrigger;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player") || other.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            other.GetComponent<Rigidbody>().velocity = Vector3.zero;
            enterTrigger.Invoke();
            if (playOnece) gameObject.SetActive(false);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            exitTrigger.Invoke();
            if (playOnece) gameObject.SetActive(false);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }

}
