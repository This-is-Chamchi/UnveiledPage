using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AntiPlayerStuck : MonoBehaviour
{
    private GameObject Player;
    private GameObject _Hansel;
    // Start is called before the first frame update
    void Start()
    {
        Player = GameObject.FindWithTag("Player");
        _Hansel = GameObject.FindWithTag("Boss");
    }

    // Update is called once per frame
    void Update()
    {
        if (_Hansel.GetComponent<Hansel>().PhaseChecker == 2)
        {
            if (Player.transform.position.x < -25.0f)  //
            {
                Player.transform.position = new Vector3(-25.0f, Player.transform.position.y, Player.transform.position.z);
            }

            if (Player.transform.position.x > 15.0f)
            {
                Player.transform.position = new Vector3(15.0f, Player.transform.position.y, Player.transform.position.z);
            }
        }
        else
        {
            if (Player.transform.position.x < -20.0f)  //
            {
                Player.transform.position = new Vector3(-20.0f, Player.transform.position.y, Player.transform.position.z);
            }

            if (Player.transform.position.x > 10.0f)
            {
                Player.transform.position = new Vector3(10.0f, Player.transform.position.y, Player.transform.position.z);
            }
        }

    }
}
