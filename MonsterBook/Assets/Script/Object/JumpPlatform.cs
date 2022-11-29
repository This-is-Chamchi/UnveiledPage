using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpPlatform : Event
{
    [SerializeField] private Vector3 direction;
    [SerializeField] private float power;

    private Collider coll;


    private void Awake()
    {
        coll = GetComponent<Collider>();
    }


    public override void StartEvent()
    {
        
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(Routine(time));
    }

    private IEnumerator Routine(float time)
    {
        coll.enabled = false;
        yield return YieldInstructionCache.waitForSeconds(time);
        coll.enabled = true;
    }


    private void OnCollisionStay(Collision collision)
    {
        if (collision.gameObject.layer == LayerMask.NameToLayer("Player") || collision.gameObject.layer == LayerMask.NameToLayer("PlayerDash"))
        {
            if (collision.transform.position.y > transform.position.y)
            {
                var rigid = collision.gameObject.GetComponent<Rigidbody>();

                if (rigid != null) rigid.AddForce(direction * power, ForceMode.Impulse);
            }
        }
    }
}
