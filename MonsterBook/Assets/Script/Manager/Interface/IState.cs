using UnityEngine;

public abstract class IState : MonoBehaviour
{
    public abstract void OnStateEnter(PlayerController player);
    public abstract void OnStateExcute(PlayerController player);
    public abstract void OnStateExit(PlayerController player);
    
}
