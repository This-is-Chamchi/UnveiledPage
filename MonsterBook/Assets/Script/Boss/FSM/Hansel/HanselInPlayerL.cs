using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselInPlayerL : MonoBehaviour
{
    // Start is called before the first frame update

    private GameObject Player;

    void Start()
    {
        Player = GameObject.FindWithTag("Player");
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            other.transform.position = new Vector3(other.transform.position.x + 0.08f, other.transform.position.y, other.transform.position.z);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            other.transform.position = new Vector3(other.transform.position.x + 0.08f, other.transform.position.y, other.transform.position.z);
        }
    }

}
