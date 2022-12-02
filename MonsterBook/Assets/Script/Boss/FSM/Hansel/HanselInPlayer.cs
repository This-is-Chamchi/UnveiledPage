using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselInPlayer : MonoBehaviour
{
    // Start is called before the first frame update

    private GameObject Player;
    private GameObject Hansel;

    void Start()
    {

        Player = GameObject.FindWithTag("Player");
        Hansel = GameObject.FindWithTag("Boss");
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            Hansel.GetComponent<Hansel>().ChangeState(BellyAttack_State.Instance);
        }
    }

    private void OnTriggerStay(Collider other)
    {
       
    }

}
