using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_StandArea : MonoBehaviour
{
    [SerializeField] private BossSceneDirector boss;
    private GameObject Anna;
    public GameObject AnnaUI;
    public GameObject Player;
    
    // Start is called before the first frame update
    void Start()
    {
        Anna = GameObject.FindWithTag("Anna");
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            Player.GetComponent<PlayerController>().SetCurHP(90);
            AnnaUI.SetActive(true);
            Anna.GetComponent<Anna>().AnnaStand();
            boss.StartStage(2);
            Destroy(this);
        }
    }

}
