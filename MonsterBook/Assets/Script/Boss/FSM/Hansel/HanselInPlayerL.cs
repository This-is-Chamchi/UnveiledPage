using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselInPlayerL : MonoBehaviour
{
    // Start is called before the first frame update

    private GameObject Player;
    private GameObject Hansel;
    private int dir;
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
        if(Player.transform.position.x > Hansel.transform.position.x)
        {
            dir = 1;
        }
        else
        {
            dir = -1;
        }

        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            other.transform.position = new Vector3(other.transform.position.x + 0.08f * dir, other.transform.position.y, other.transform.position.z);
        }
    }

    private void OnTriggerStay(Collider other)
    {

        if (Player.transform.position.x > Hansel.transform.position.x)
        {
            dir = 1;
        }
        else
        {
            dir = -1;
        }

        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            other.transform.position = new Vector3(other.transform.position.x + 0.08f * dir, other.transform.position.y, other.transform.position.z);
        }
    }

}
